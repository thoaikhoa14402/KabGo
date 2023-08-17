import { Routes, Route } from "react-router-dom";
import BaseLayout from "@layouts/BaseLayout";
import Dashboard from "@components/Dashboard";
import Admin from "@components/Admin";
import Driver from "@components/Driver";
import Customer from "@components/Customer";
import Service from "@components/Service";
import Vehicle from "@components/Vehicle";
import Invoice from "@components/Invoice";
import NewAccount from "@components/NewAccount";

const AppRoutes: React.FC = () => {
  return (
    <Routes>
      <Route element={<BaseLayout />}>
        <Route path="/" element={<Dashboard />} />
        <Route path="/admin">
          <Route index element={<Admin />} />
          <Route path="create" element={<NewAccount />} />
        </Route>
        <Route path="/driver">
          <Route index element={<Driver />} />
          <Route path="create" element={<NewAccount />} />
        </Route>
        <Route path="/customer">
          <Route index element={<Customer />} />
          <Route path="create" element={<NewAccount />} />
        </Route>
        <Route path="/service" element={<Service />} />
        <Route path="/vehicle" element={<Vehicle />} />
        <Route path="/invoice" element={<Invoice />} />
      </Route>
    </Routes>
  );
};

export default AppRoutes;
