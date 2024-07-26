import os
import time
import threading
import json
import collections
from uuid import uuid4
from datetime import datetime
from dataclasses import dataclass, asdict

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib


def main():
    DBusGMainLoop(set_as_default=True)
    NotificationServer()
    mainloop = GLib.MainLoop()
    mainloop.run()


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
    def __init__(self, max: int, timeout: float = 0.0):
        self.notifications: collections.deque[Notification] = collections.deque([], maxlen=max)
        self.timeout = timeout

    def echo(self):
        print(list(self.notifications), flush=True)

    def push(self, notification: Notification):
        self.notifications.appendleft(notification)
        self.echo()

        if self.timeout:
            timer_thread = threading.Thread(target=self.dismiss)
            timer_thread.start()

    def dismiss(self):
        if self.timeout:
            time.sleep(self.timeout)

        self.notifications.pop()
        self.echo()

    def dismiss_all(self):
        self.notifications.clear()
        self.echo()


notification_manager = NotificationsManager(max=5, timeout=10)


def initialize_json_file():
    if not os.path.exists("notifications.json"):
        with open("notifications.json", 'w') as f:
            json.dump([], f)

def write_to_json(notification: Notification):
    with open("notifications.json", 'r') as f:
        notifications = json.load(f)
    
    notifications.append(asdict(notification))
    
    with open("notifications.json", 'w') as f:
        json.dump(notifications, f, indent=4)


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
        write_to_json(notification)
        notification_manager.push(notification)

        return 0


if __name__ == "__main__":
    main()
