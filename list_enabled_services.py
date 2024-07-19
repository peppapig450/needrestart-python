import sdbus
from sdbus_block.systemd import Systemd
from pprint import pprint
from dataclasses import dataclass


@dataclass
class SystemdUnitInfo:
    name: str
    description: str
    load_status: str
    active_status: str
    sub_state: str
    following: str
    unit_path: str
    job_id: int
    job_type: str
    job_path: str


services: dict[str, SystemdUnitInfo] = {}

systemd = Systemd(sdbus.sd_bus_open_system())
units = systemd.list_units()

for unit in units:
    services[unit[0]] = SystemdUnitInfo(*unit)

pprint(services, indent=4)
