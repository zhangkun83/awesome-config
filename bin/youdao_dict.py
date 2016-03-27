#!/usr/bin/env python

# A simple interface that let you input a word and look it up in Youdao Web Dict

import pygtk
pygtk.require('2.0')
import gtk
import os
import urllib;

class youdao_dict:

    # This is a callback function. The data arguments are ignored
    # in this example. More on callbacks below.
    def query(self, widget, data=None):
        query = urllib.quote(self.input_box.get_text())
        print query
        if widget == self.youdao_button:
          url = "http://www.iciba.com/" + query
        elif widget == self.jisho_button:
          url = "http://dictionary.goo.ne.jp/srch/all/" + query + "/m0u/"
        else:
          url = "http://www.google.com/search?q=" + query
        os.system("google-chrome --app=" + url + " &")

    def delete_event(self, widget, event, data=None):
        # If you return FALSE in the "delete_event" signal handler,
        # GTK will emit the "destroy" signal. Returning TRUE means
        # you don't want the window to be destroyed.
        # This is useful for popping up 'are you sure you want to quit?'
        # type dialogs.
        print "delete event occurred"

        # Change FALSE to TRUE and the main window will not be destroyed
        # with a "delete_event".
        return False

    def destroy(self, widget, data=None):
        print "destroy signal occurred"
        gtk.main_quit()

    def read_clipboard(self):
        cb = gtk.Clipboard(selection="PRIMARY")
        word = cb.wait_for_text()
        if word != None:
            return word
        cb = gtk.Clipboard(selection="CLIPBOARD")
        word = cb.wait_for_text()
        if word != None:
            return word
        return ""

    def __init__(self):
        # create a new window
        self.window = gtk.Dialog()
        self.window.set_title("Quick Search")
        self.window.set_position(gtk.WIN_POS_CENTER)
        self.window.set_default_size(400, 0)
        self.window.set_property("allow-grow", False)
        
        # When the window is given the "delete_event" signal (this is given
        # by the window manager, usually by the "close" option, or on the
        # titlebar), we ask it to call the delete_event () function
        # as defined above. The data passed to the callback
        # function is NULL and is ignored in the callback function.
        self.window.connect("delete_event", self.delete_event)
    
        # Here we connect the "destroy" event to a signal handler.  
        # This event occurs when we call gtk_widget_destroy() on the window,
        # or if we return FALSE in the "delete_event" callback.
        self.window.connect("destroy", self.destroy)
    
        # Sets the border width of the window.
        self.window.set_border_width(10)

        self.input_box = gtk.Entry()
        self.input_box.set_activates_default(True)
        self.input_box.set_size_request(400, -1)
        self.input_box.set_text(self.read_clipboard())

    
        # Creates a new button
        self.youdao_button = gtk.Button("_Iciba")
        self.youdao_button.set_size_request(-1, -1)
        # let the button can be set as the default widget of the window
        self.youdao_button.set_flags(gtk.CAN_DEFAULT)

        # Button for Japanese dictionary
        self.jisho_button = gtk.Button("_Jisho")
        self.jisho_button.set_size_request(-1, -1)

        # Button for google search
        self.google_button = gtk.Button("_Google")
        self.google_button.set_size_request(-1, -1)
    
        # When the button receives the "clicked" signal, it will call the
        # function hello() passing it None as its argument.  The hello()
        # function is defined above.
        self.youdao_button.connect("clicked", self.query, None)
        self.jisho_button.connect("clicked", self.query, None)
        self.google_button.connect("clicked", self.query, None)
    
        # This will cause the window to be destroyed by calling
        # gtk_widget_destroy(window) when "clicked".  Again, the destroy
        # signal could come from here, or the window manager.
        self.youdao_button.connect_object("clicked", gtk.Widget.destroy, self.window)
        self.jisho_button.connect_object("clicked", gtk.Widget.destroy, self.window)
        self.google_button.connect_object("clicked", gtk.Widget.destroy, self.window)
    
        # This packs the button into the window (a GTK container).
        text_msg = gtk.Label("Anything to search:")
        self.window.get_content_area().add(text_msg)
        self.window.get_content_area().add(self.input_box)
        self.window.add_action_widget(self.youdao_button, 1)
        self.window.add_action_widget(self.jisho_button, 1)
        self.window.add_action_widget(self.google_button, 3)
        self.window.set_default(self.youdao_button)
    
        # The final step is to display this newly created widget.
        self.youdao_button.show()
        self.jisho_button.show()
        self.google_button.show()
        self.input_box.show()
        text_msg.show()
    
        # and the window
        self.window.show()

    def main(self):
        # All PyGTK applications must have a gtk.main(). Control ends here
        # and waits for an event to occur (like a key press or mouse event).
        gtk.main()

# If the program is run directly or passed as an argument to the python
# interpreter then create a HelloWorld instance and show it
if __name__ == "__main__":
    hello = youdao_dict()
    hello.main()
