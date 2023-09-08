import rabbitmq from '@common/rabbitmq';
import express from 'express';
import mongoose from 'mongoose';
import bodyParser from 'body-parser';
import morgan from 'morgan';
import chalk from 'chalk';
import { Server } from 'http';
import Controller from './interfaces/controller';
import ConsoleProxyHandler from '@common/utils/console.proxy';
import Logger from './utils/logger';

type RabbitMQConnection = {
    uri: string;
};

type MongoConnection = {
    uri: string;
    options?: mongoose.ConnectOptions;
};

type ApplicationOptions = {
    controllers: Controller[];
    mongoConnection: MongoConnection;
    rabbitMQConnection: RabbitMQConnection;
};

class Application {
    private app: express.Application;
    private controllers: Controller[] = [];
    private mongoConnection: MongoConnection;
    private rabbitMQConnection: RabbitMQConnection;

    constructor(options: ApplicationOptions) {
        this.app = express();
        this.controllers = options.controllers;
        this.mongoConnection = options.mongoConnection;
        this.rabbitMQConnection = options.rabbitMQConnection;

        console = new Proxy(console, new ConsoleProxyHandler());

        this.setup();
        this.mongoDBConnect(this.mongoConnection.uri, this.mongoConnection.options);
    }

    public application() {
        return this.app;
    }

    private setup() {
        console.log('Setting up request middleware...');

        this.app.use(bodyParser.json({ limit: '50mb' }));
        this.app.use(bodyParser.urlencoded({ extended: true }));

        this.app.use(
            morgan(
                `${chalk.blue(
                    `[${process.env.APP_NAME}]`
                )}${chalk.yellow('[:date]')} ${chalk.green(
                    ':method'
                )} ${chalk.cyan(':status')} ${chalk.white(':url')} :res[content-length] - :response-time ms`
            )
        );

        this.app.use(morgan(`[${process.env.APP_NAME}][:date] :method :status :url :res[content-length] - :response-time ms`, {
            stream: new Logger('./logs/access.log').createWritableStream(),
        }));
        
        this.controllers.forEach((controller) => this.app.use(controller.path, controller.router));

        this.app.get('/status', (req, res) => {
            return res.json({ status: '200 - OK', message: 'Server is running ...' });
        });
    }

    public mongoDBConnect(uri: string, options: mongoose.ConnectOptions = {}): void {
        mongoose
            .connect(uri, options)
            .then(() => {
                console.log('Connected to database successfully');
            })
            .catch((error) => {
                console.log('Could not connect to the database', error);
            });
    }

    private async rabbitMQConnect(uri: string) {
        await rabbitmq.connect(uri);
    }

    public run(port: number = 3000, callback: Function = () => {}): Server {
        console.log('Server is starting...');

        const availablePort = process.env.PORT ?? port;

        return this.app.listen(availablePort, async () => {
            console.log(`Server is running on port ${availablePort}`);

            await this.rabbitMQConnect(this.rabbitMQConnection.uri);
            callback();
        });
    }
}

export default Application;

