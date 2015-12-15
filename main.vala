namespace Client
{
    public int main(string[] args)
    {
        Gtk.init(ref args);
        ClientUI client_ui = new ClientUI();
        client_ui.main_window.show_all();
        Gtk.main();
        return 0;
    }
}
