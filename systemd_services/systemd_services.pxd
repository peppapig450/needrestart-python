cdef extern from "systemd/sd-bus.h":
    ctypedef struct sd_bus_message
    ctypedef struct sd_bus

    int sd_bus_open_system(sd_bus **bus)
    int sd_bus_get_property(
        sd_bus *bus,
        char *destination,
        char *path,
        char *interface,
        char *member,
        sd_bus_message **reply,
        char *type
    )
    int sd_bus_message_read(sd_bus_message *m, char *types, ...)
    int sd_bus_message_enter_container(sd_bus_message* m, char type, char *contents)
    int sd_bus_message_exit_container(sd_bus_message *m)
    int sd_bus_message_unref(sd_bus_message *m)
    int sd_bus_unref(sd_bus *bus)
    int sd_bus_call_method(
        sd_bus *bus,
        char *destination,
        char *path,
        char *interface,
        char *method,
        sd_bus_message **reply,
        char *type,
        ...
    )