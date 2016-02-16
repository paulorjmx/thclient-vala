using Gtk;

namespace Client
{
    public class ClientUI : Object
    {
        private ClientSocket _client = new ClientSocket("127.0.0.1", 8000);
        private Window _main_window;
        private Dialog _prefs_dialog;
        private Entry _ip_entry;
        private Entry _port_entry;
        private ImageMenuItem _preferences;
        private ImageMenuItem _img_connect;
        private ImageMenuItem _img_disconnect;
        private Button _btn_send;
        private TextView _msg;
        private Builder _builder;

        public ClientUI()
        {
            _builder = new Builder.from_file("ui/client.ui");
            _main_window =  _builder.get_object("main_window") as Gtk.Window;
            _prefs_dialog = _builder.get_object("dialog_prefs") as Dialog;
            _prefs_dialog.add_button("_OK", ResponseType.OK);
            _prefs_dialog.add_button("_Cancel", ResponseType.CANCEL);
            _preferences = _builder.get_object("img_prefs") as ImageMenuItem;
            _img_connect = _builder.get_object("img_connect") as ImageMenuItem;
            _img_disconnect = _builder.get_object("img_disconnect") as ImageMenuItem;
            _ip_entry = _builder.get_object("entry_ip") as Entry;
            _port_entry = _builder.get_object("entry_port") as Entry;
            _msg = _builder.get_object("msg") as TextView;
            _btn_send = _builder.get_object("btn_send") as Button;
            connect_events();
        }

        //Properties
        public Gtk.Window main_window
        {
            private set { }
            get
            {
                return _main_window;
            }
        }

        private void connect_events()
        {
            _main_window.destroy.connect(on_main_main_window_destroy);
            _img_connect.activate.connect(on_connect_activate);
            _img_disconnect.activate.connect(on_disconnect_activate);
            _preferences.activate.connect(on_preferences_activated);
            _prefs_dialog.delete_event.connect(on_dialog_prefs_close);
            _prefs_dialog.response.connect(on_prefs_dialog_response);
            _btn_send.clicked.connect(on_btn_send_clicked);
        }

        // Events Methods
        private void on_connect_activate()
        {
            _client.connect_to_server();
        }

        private void on_btn_send_clicked()
        {
            _client.send_data(_msg.buffer.text.data);
        }

        private void on_disconnect_activate()
        {
            _client.send_data("SHT_CLI".data);
            _client.disconnect();
        }

        private void on_main_main_window_destroy()
        {
            _client.send_data("SHT_CLI".data);
            _client.disconnect();
            Gtk.main_quit();
        }

        private void on_preferences_activated()
        {
            _prefs_dialog.show();
        }

        private bool on_dialog_prefs_close(Gdk.EventAny e)
        {
            if(e.type == Gdk.EventType.DELETE)
            {
                _prefs_dialog.hide_on_delete();
                return true;
            }
            else
            {
                return false;
            }
        }

        private void on_prefs_dialog_response(int id_response)
        {
            switch(id_response)
            {
                case ResponseType.OK:
                    if(_ip_entry.text == "")
                    {
                        // Error message
                        MessageDialog _msg_dialog = new MessageDialog(_main_window, DialogFlags.MODAL, MessageType.WARNING, ButtonsType.OK, "O campo IP Address não pode ficar vazio!");
                        _msg_dialog.set_title("Warning!");
                        _msg_dialog.show_all();
                        _msg_dialog.destroy.connect( (s) =>
                        {
                                _msg_dialog.destroy();
                        });
                        _msg_dialog.response.connect( (s, r) =>
                        {
                            switch(r)
                            {
                                case ResponseType.OK:
                                    _msg_dialog.destroy();
                                    break;

                                default:
                                    _msg_dialog.destroy();
                                    break;
                            }
                        });
                    }
                    else
                    {
                        if(_port_entry.text == "")
                        {
                            // Error message
                            MessageDialog _msg_dialog = new MessageDialog(_main_window, DialogFlags.MODAL, MessageType.WARNING, ButtonsType.OK_CANCEL, "O campo port não pode ficar vazio!");
                            _msg_dialog.set_title("Warning!");
                            _msg_dialog.show_all();
                            _msg_dialog.destroy.connect( (s) =>
                            {
                                    _msg_dialog.close();
                            });
                            _msg_dialog.response.connect( (s, r) =>
                            {
                                switch(r)
                                {
                                    case ResponseType.OK:
                                        _msg_dialog.close();
                                        break;

                                    default:
                                        _msg_dialog.close();
                                        break;
                                }
                            });
                        }
                        else
                        {
                            /*_client.inet_client_address = new InetSocketAddress.from_string(_ip_entry.get_text(), (uint) _port_entry.text);*/
                            _prefs_dialog.hide_on_delete();
                        }
                    }
                    break;

                case ResponseType.CANCEL:
                    _prefs_dialog.hide_on_delete();
                    break;

                default:
                    _prefs_dialog.hide_on_delete();
                    break;
            }
        }
    }
}
