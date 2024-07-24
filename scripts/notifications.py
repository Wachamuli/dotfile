import json
import collections
from dataclasses import dataclass, asdict
from uuid import uuid4
from datetime import datetime

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import threading
import time


def main():
    DBusGMainLoop(set_as_default=True)
    NotificationServer()
    mainloop = GLib.MainLoop()
    mainloop.run()
    # dbus_thread = threading.Thread(target=start_dbus_server)
    # dbus_thread.start()

    # user_input_thread()


def start_dbus_server():
    DBusGMainLoop(set_as_default=True)
    NotificationServer()
    mainloop = GLib.MainLoop()
    mainloop.run()


# def user_input_thread():
#     while True:
#         command = input("Enter command (dismiss/dimiss_all/do_not_disturb): ").strip().lower()

#         match command:
#             case "dismiss":
#                 raise NotImplementedError
#             case "dismiss_all":
#                 raise NotImplementedError
#             case "do_not_disturb":
#                 raise NotImplementedError
#             case _:
#                 raise NotImplementedError


@dataclass()
class Notification:
    id: str
    timestamp: str
    app_name: str
    summary: str
    body: str
    app_icon: str

    def __repr__(self) -> str:
        return json.dumps(asdict(self))


class NotificationsManager:
    def __init__(self, max_notifications: int, dimiss_time: float = 0.0):
        self.notifications: collections.deque[Notification] = collections.deque([], maxlen=max_notifications)
        self.dismiss_time = dimiss_time

    def show(self):
        print(list(self.notifications), flush=True)

    def push(self, notification: Notification):
        self.notifications.appendleft(notification)
        self.show()

        if self.dismiss_time:
            timer_thread = threading.Thread(target=self.dismiss)
            timer_thread.start()

    def dismiss(self):
        if self.dismiss_time:
            time.sleep(self.dismiss_time)

        self.notifications.pop()
        self.show()


# static_notification_manager = NotificationsManager(20)
temporal_notification_manager = NotificationsManager(5, 10)

# def foo():
#     print("{ 'static': %s, 'temporal': %s }" % (list(static_notification_manager.notifications), list(temporal_notification_manager.notifications)))

#     timer_thread = threading.Thread(target=temporal_notification_manager.dismiss)
#     timer_thread.start()
#     time.sleep(10)

#     print("{ 'static': %s, 'temporal': %s }" % (list(static_notification_manager.notifications), list(temporal_notification_manager.notifications)))


class NotificationServer(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName("org.freedesktop.Notifications", bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, "/org/freedesktop/Notifications")

    @dbus.service.method("org.freedesktop.Notifications", out_signature="ssss")
    def GetServerInformation(self):
        return ("Custom Notification Server", "ExampleNS", "1.0", "1.2")

    @dbus.service.method("org.freedesktop.Notifications", in_signature="susssasa{ss}i", out_signature="u")
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout):
        id = str(uuid4())
        raw_timestamp = datetime.now()
        timestamp = raw_timestamp.strftime("%I:%M %p")

        notification = Notification(id, timestamp, app_name, summary, body, app_icon)
        temporal_notification_manager.push(notification)
        # static_notification_manager.push(notification)

        return 0


if __name__ == "__main__":
    main()
