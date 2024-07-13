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


class NotificationsManager:
    def __init__(self, max_notifications: int, dimiss_time: float = 0.0):
        self.notifications: collections.deque[Notification] = collections.deque([], maxlen=max_notifications)
        self.dismiss_time = dimiss_time

    def show_notifications(self):
        print(list(self.notifications), flush=True)

    def add_notification(self, notification: Notification):
        self.notifications.appendleft(notification)
        self.show_notifications()

        if self.dismiss_time:
            timer_thread = threading.Thread(target=self.remove_notification)
            timer_thread.start()

    def remove_notification(self):
        if self.dismiss_time:
            time.sleep(self.dismiss_time)

        self.notifications.pop()
        self.show_notifications()


# notification_control = NotificationsManager(10)
notification_queue = NotificationsManager(5, 10)


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
        # notification_control.add_notification(notification)
        notification_queue.add_notification(notification)
        return 0


if __name__ == "__main__":
    main()
