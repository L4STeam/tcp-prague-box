import subprocess

from ipmininet.clean import cleanup
from ipmininet.cli import IPCLI
from ipmininet.ipnet import IPNet
from ipmininet.iptopo import IPTopo
from ipmininet.router.config import OSPF
from ipmininet.router.config.base import RouterConfig
from ipmininet.router.config.ospf import OSPFRedistributedRoute


class MinimalDCTCPNet(IPTopo):
    """

    client1 ---- r1 ---- r2 ---- r3 ---- server1
                 |                |
    client2 ---- +                + ---- server2

    """
    def __init__(self, *args, **kwargs):
        super(MinimalDCTCPNet, self).__init__(*args, **kwargs)

    def build(self, *args, **kwargs):
        r1 = self.addRouter("r1", config=RouterConfig)
        r1.addDaemon(OSPF)
        r2 = self.addRouter("r2", config=RouterConfig)
        r2.addDaemon(OSPF)
        r3 = self.addRouter("r3", config=RouterConfig)
        r3.addDaemon(OSPF)
        self.addLink(r1, r2, params1={"ip": "10.0.0.1/24"}, params2={"ip": "10.0.0.2/24"})
        self.addLink(r2, r3, params1={"ip": "10.0.1.1/24"}, params2={"ip": "10.0.1.2/24"})

        client1 = self.addHost("client1")
        self.addLink(r1, client1, params1={"ip": "10.1.0.1/24"}, params2={"ip": "10.1.0.2/24"})
        client2 = self.addHost("client2")
        self.addLink(r1, client2, params1={"ip": "10.1.1.1/24"}, params2={"ip": "10.1.1.2/24"})

        server1 = self.addHost("server1")
        self.addLink(r3, server1, params1={"ip": "10.2.0.1/24"}, params2={"ip": "10.2.0.2/24"})
        server2 = self.addHost("server2")
        self.addLink(r3, server2, params1={"ip": "10.2.1.1/24"}, params2={"ip": "10.2.1.2/24"})

        super(MinimalDCTCPNet, self).build(*args, **kwargs)

if __name__ == "__main__":
    try:
        subprocess.check_call(["modprobe", "tcp_dctcp"])
        net = IPNet(topo=MinimalDCTCPNet(), allocate_IPs=False)
        net.start()

        # Set DCTCP Congestion Control on client1 and server1 and cubic for the others
        net["client1"].cmd("sysctl -w net.ipv4.tcp_congestion_control=dctcp")
        net["server1"].cmd("sysctl -w net.ipv4.tcp_congestion_control=dctcp")
        net["client2"].cmd("sysctl -w net.ipv4.tcp_congestion_control=cubic")
        net["server2"].cmd("sysctl -w net.ipv4.tcp_congestion_control=cubic")

        # Setup AQM dc_dualq
        net["r2"].cmd("tc qdisc del dev r2-eth0")
        net["r2"].cmd("tc qdisc add dev r2-eth0 root handle 1:0 htb default 1 direct_qlen 1000")
        net["r2"].cmd("tc class add dev r2-eth0 parent 1:0 classid 1:1 htb rate 40Mbit ceil 40Mbit")
        net["r2"].cmd("tc qdisc add dev r2-eth0 parent 1:1 handle 2:0 dualpi2 target 20ms dc_ecn l_thresh 1ms dc_dualq limit 1000")

        # Instructions for tests
        print("You can run the following commands to produce DCTCP traffic")
        print("client1 netserver -p 16604 > client1.log &")
        print("server1 netperf -H  10.1.0.1 -p 16604 -l 20 > server1.log &")
        print("You can run the following commands to produce Cubic traffic")
        print("client2 netserver -p 16604 > client2.log &")
        print("server2 netperf -H  10.1.1.1 -p 16604 -l 20 > server2.log")
        print("Use 'exit' to exit the network")

        IPCLI(net)
        net.stop()
    finally:
        cleanup()

