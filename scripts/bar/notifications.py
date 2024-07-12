from dataclasses import dataclass, asdict
import collections
import json
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


@dataclass()
class Notification:
    app_name: str
    summary: str
    body: str
    app_icon: str

    def __repr__(self) -> str:
        return json.dumps(asdict(self))


class NotificationManager:
    notifications: collections.deque[Notification] = collections.deque([], maxlen=5)

    @staticmethod
    def show_notifications():
        print(list(NotificationManager.notifications), flush=True)

    @staticmethod
    def add_notification(notification: Notification):
        NotificationManager.notifications.appendleft(notification)
        NotificationManager.show_notifications()
        timer_thread = threading.Thread(target=NotificationManager.remove_notification)
        timer_thread.start()

    @staticmethod
    def remove_notification():
        time.sleep(10)
        NotificationManager.notifications.pop()
        NotificationManager.show_notifications()


class NotificationServer(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName("org.freedesktop.Notifications", bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, "/org/freedesktop/Notifications")

    @dbus.service.method("org.freedesktop.Notifications", out_signature="ssss")
    def GetServerInformation(self):
        return ("Custom Notification Server", "ExampleNS", "1.0", "1.2")

    @dbus.service.method("org.freedesktop.Notifications", in_signature="susssasa{ss}i", out_signature="u")
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout):
        notification = Notification(app_name, summary, body, app_icon)
        NotificationManager.add_notification(notification)
        return 0


if __name__ == "__main__":
    main()
