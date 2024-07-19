# cython: language_level=3
# distutils: language = c++

from libc.string cimport strdup
from systemd_services cimport sd_bus, sd_bus_message, sd_bus_open_system, sd_bus_get_property,  sd_bus_message_read, sd_bus_message_enter_container, sd_bus_message_exit_container, sd_bus_message_unref, sd_bus_unref, sd_bus_call_method
from cpython cimport PyObject
from cpython.dict cimport PyDict_New, PyDict_SetItemString
from cpython.unicode cimport PyUnicode_DecodeUTF8

cdef class SystemdServiceManager:
    cdef sd_bus *sd_bus

    def __cinit__(self):
        cdef sd_bus *tmp_bus = NULL
        if sd_bus_open_system(&tmp_bus) < 0:
            raise RuntimeError("Failed to connect to system bus")
        self.bus = tmp_bus

    def __dealloc__(self):
        if self.bus:
            sd_bus_unref(self.bus)
    
    def list_all_services(self):
        cdef sd_bus_message *m = NULL
        cdef char *unit_name
        cdef char *description
        cdef char *load_state
        cdef char *active_state
        cdef char *sub_state
        cdef char *following
        cdef int r

        # Get the list of units
        r = sd_bus_call_method(
            self.bus,
            "org.freedesktop.systemd1",
            "/org/freedesktop/systemd1",
            "org.freedesktop.systemd1.Manager",
            "ListUnits",
            &m,
            "a(ssssouso)",
            NULL
        )
        if r < 0:
            raise RuntimeError("Failed to get list of services")

        r = sd_bus_message_enter_container(m, 'a', "(ssssouso)")
        if r < 0:
            sd_bus_message_unref(m)
            raise RuntimeError("Failed to enter container")

        while sd_bus_message_read(m, "(ssssouso)", &unit_name, &description, &load_state, &active_state, &sub_state, &following) > 0:
            service_info = PyDict_New()
            PyDict_SetItemString(service_info, "Description", PyUnicode_DecodeUTF8(description, -1, NULL))
            PyDict_SetItemString(service_info, "LoadState", PyUnicode_DecodeUTF8(load_state, -1, NULL))
            PyDict_SetItemString(service_info, "ActiveState", PyUnicode_DecodeUTF8(active_state, -1, NULL))
            PyDict_SetItemString(service_info, "SubState", PyUnicode_DecodeUTF8(sub_state, -1, NULL))
            PyDict_SetItemString(service_info, "Following", PyUnicode_DecodeUTF8(following, -1, NULL))

            PyDict_SetItemString(services, unit_name, service_info)
        
        sd_bus_message_exit_container(m)
        sd_bus_message_unref(m)
        return services