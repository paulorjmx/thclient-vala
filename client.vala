namespace Client
{
    public class ClientSocket : Object
    {
        private Thread<int> th_receive;
        private Socket _client;
        private InetSocketAddress address;

        public ClientSocket(string ip_address, uint16 port)
        {
            address = new InetSocketAddress.from_string(ip_address, port);
            _client = new Socket(SocketFamily.IPV4, SocketType.STREAM, SocketProtocol.TCP);
            stdout.printf("\n%s\n", (string) _client.get_keepalive());
        }

        public void connect_to_server()
        {
            _client.connect(address);
            if(_client.is_connected() == true)
            {
                stdout.printf("\nCliente conectado ao servidor!\n");
                this.begin_receive.begin( (obj, res) =>
                {
                    this.begin_receive.end(res);
                });
            }
            else
            {
                stdout.printf("\nErro ao tentar se conectar ao servidor!\n");
            }
        }


        public async void begin_receive()
        {
            if(Thread.supported() == true)
            {
                th_receive = new Thread<int>.try("receive_data", receive_data);
            }
            else
            {
                stdout.printf("\nO sistema nao possui suporte para threads!\n");
            }
        }

        private int receive_data()
        {
            while(true)
            {
                if(_client.is_connected() == true)
                {
                    if(_client.condition_wait(IOCondition.IN))
                    {
                        uint8[] _buffer = new uint8[256];
                        ssize_t len = _client.receive(_buffer);
                        stdout.write(_buffer, len);
                    }
                    else
                    {
                        continue;
                    }
                }
                else
                {
                    stdout.printf("\nO cliente nao esta conectado ao servidor!\n");
                }
            }
        }

        public void send_data(uint8[] data_to_send)
        {
            if(_client.is_connected() == true)
            {
                _client.send(data_to_send);
            }
            else
            {
                stdout.printf("\nO cliente nao esta conectado ao servidor!\n");
            }
        }

        public void disconnect()
        {
            _client.shutdown(true, true);
            _client.close();
        }
    }
}
