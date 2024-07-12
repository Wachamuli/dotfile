from dataclasses import dataclass
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import threading
import time


def main():
    DBusGMainLoop(set_as_default=True)
    _ = NotificationServer()
    mainloop = GLib.MainLoop()
    mainloop.run()


@dataclass()
class Notification:
    app_name: str
    summary: str
    body: str
    app_icon: str
    

class NotificationManager:
    notifications: list[Notification] = []

    @staticmethod
    def remove_notification(notification: Notification):
        time.sleep(10)
        NotificationManager.notifications.remove(notification)
        NotificationManager.show_notifications()

    @staticmethod
    def add_notification(notification: Notification):
        NotificationManager.notifications.insert(0, notification)
        NotificationManager.show_notifications()
        timer_thread = threading.Thread(target=NotificationManager.remove_notification, args=(notification,))
        timer_thread.start()

    @staticmethod
    def show_notifications():
        notification = ""
        
        for data in NotificationManager.notifications:
            notification += fr"""
            (box
                :class "notification-container"
                :width 500
                :spacing 20
                :space-evenly false
                (image :image-width 80 :image-height 80 :path "{data.app_icon}")
                (box
                    :orientation "v"
                    :space-evenly false
                    :valign "center"
                    :hexpand true
                    (label :halign "start"  :limit-width 100 :style "font-weight: bold; font-size: 16px; margin-bottom: 10px" :text "{data.app_name}")
                    (label :halign "start"  :limit-width 100 :style "font-weight: bold" :text "{data.summary}")
                    (label :halign "start"  :limit-width 100 :text "{data.body}")
                )
            )
            """

        notification = notification.replace("\n", " ")
        print(fr'''(box :orientation "v" :spacing 20 {notification or ''})''', flush=True)


class NotificationServer(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName('org.freedesktop.Notifications', bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '/org/freedesktop/Notifications')

    @dbus.service.method('org.freedesktop.Notifications', out_signature='ssss')
    def GetServerInformation(self):
        return ("Custom Notification Server", "ExampleNS", "1.0", "1.2")

    @dbus.service.method('org.freedesktop.Notifications', in_signature='susssasa{ss}i', out_signature='u')
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, timeout):
        notification = Notification(
            app_name,
            summary,
            body,
            app_icon
        )
        NotificationManager.add_notification(notification)
        return 0



if __name__ == '__main__':
    main()