@echo off

rem Configuration
set "hosts_file=C:\Windows\System32\drivers\etc\hosts"
set "ip_address=127.0.0.1"

set "host_name_auth_api=api.auth.kabgo.local"
set "host_name_driver_api=api.driver.kabgo.local"
set "host_name_customer_api=api.customer.kabgo.local"
set "host_name_admin_api=api.admin.kabgo.local"
set "host_name_call_center_api=api.call-center.kabgo.local"
set "host_name_call_center_api_s2=api.call-center-s2.kabgo.local"
set "host_name_call_center_api_s3=api.call-center-s3.kabgo.local"
set "host_name_gps_coordinates=api.gps-coordinates.kabgo.local"

set "host_name_admin=admin.kabgo.local"
set "host_name_call_center=call-center.kabgo.local"
set "host_name_kafka=kafka.kabgo.local"
set "host_name_rabbitmq=rabbitmq.kabgo.local"

rem Check if the entries already exist
findstr /C:"%host_name_admin%" "%hosts_file%" >nul && (
    echo Entry "%host_name_admin%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_admin% >> "%hosts_file%"
    echo New entry "%host_name_admin%" added to the hosts file.
)
findstr /C:"%host_name_call_center%" "%hosts_file%" >nul && (
    echo Entry "%host_name_call_center%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_call_center% >> "%hosts_file%"
    echo New entry "%host_name_call_center%" added to the hosts file.
)
findstr /C:"%host_name_auth_api%" "%hosts_file%" >nul && (
    echo Entry "%host_name_auth_api%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_auth_api% >> "%hosts_file%"
    echo New entry "%host_name_auth_api%" added to the hosts file.
)
findstr /C:"%host_name_driver_api%" "%hosts_file%" >nul && (
    echo Entry "%host_name_driver_api%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_driver_api% >> "%hosts_file%"
    echo New entry "%host_name_driver_api%" added to the hosts file.
)
findstr /C:"%host_name_customer_api%" "%hosts_file%" >nul && (
    echo Entry "%host_name_customer_api%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_customer_api% >> "%hosts_file%"
    echo New entry "%host_name_customer_api%" added to the hosts file.
)
findstr /C:"%host_name_admin_api%" "%hosts_file%" >nul && (
    echo Entry "%host_name_admin_api%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_admin_api% >> "%hosts_file%"
    echo New entry "%host_name_admin_api%" added to the hosts file.
)
findstr /C:"%host_name_call_center_api%" "%hosts_file%" >nul && (
    echo Entry "%host_name_call_center_api%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_call_center_api% >> "%hosts_file%"
    echo New entry "%host_name_call_center_api%" added to the hosts file.
)
findstr /C:"%host_name_call_center_api_s2%" "%hosts_file%" >nul && (
    echo Entry "%host_name_call_center_api_s2%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_call_center_api_s2% >> "%hosts_file%"
    echo New entry "%host_name_call_center_api_s2%" added to the hosts file.
)
findstr /C:"%host_name_call_center_api_s3%" "%hosts_file%" >nul && (
    echo Entry "%host_name_call_center_api_s3%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_call_center_api_s3% >> "%hosts_file%"
    echo New entry "%host_name_call_center_api_s3%" added to the hosts file.
)
findstr /C:"%host_name_kafka%" "%hosts_file%" >nul && (
    echo Entry "%host_name_kafka%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_kafka% >> "%hosts_file%"
    echo New entry "%host_name_kafka%" added to the hosts file.
)
findstr /C:"%host_name_rabbitmq%" "%hosts_file%" >nul && (
    echo Entry "%host_name_rabbitmq%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_rabbitmq% >> "%hosts_file%"
    echo New entry "%host_name_rabbitmq%" added to the hosts file.
)
findstr /C:"%host_name_gps_coordinates%" "%hosts_file%" >nul && (
    echo Entry "%host_name_gps_coordinates%" already exists in the hosts file.
) || (
    echo %ip_address% %host_name_gps_coordinates% >> "%hosts_file%"
    echo New entry "%host_name_gps_coordinates%" added to the hosts file.
)
