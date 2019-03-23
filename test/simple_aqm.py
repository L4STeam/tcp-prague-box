from ipmininet.clean import cleanup
from ipmininet.cli import IPCLI
from ipmininet.ipnet import IPNet
from ipmininet.iptopo import IPTopo
from ipmininet.router.config import OSPF
from ipmininet.router.config.base import RouterConfig
from ipmininet.router.config.ospf import OSPFRedistributedRoute


class MinimalAQMNet(IPTopo):
    """

    client1 ---- r1 ---- r2 ---- r3 ---- server1
                 |                |
    client2 ---- +                + ---- server2

    """
    def __init__(self, *args, **kwargs):
        super(MinimalAQMNet, self).__init__(*args, **kwargs)

    def build(self, *args, **kwargs):
        r1 = self.addRouter("r1", config=RouterConfig)
        r1.addDaemon(OSPF)
        r2 = self.addRouter("r2", config=RouterConfig)
        r2.addDaemon(OSPF)
        r3 = self.addRouter("r3", config=RouterConfig)
        r3.addDaemon(OSPF)
        self.addLink(r1, r2)
        self.addLink(r2, r3)

        client1 = self.addHost("client1")
        self.addLink(r1, client1)
        client2 = self.addHost("client2")
        self.addLink(r1, client2)

        server1 = self.addHost("server1")
        self.addLink(r3, server1)
        server2 = self.addHost("server2")
        self.addLink(r3, server2)

        super(MinimalAQMNet, self).build(*args, **kwargs)

if __name__ == "__main__":
    try:
        net = IPNet(topo=MinimalAQMNet())
        net.start()

        # Setup AQM l4s_dualq
        net["r2"].cmd("tc qdisc del dev r2-eth0")
        net["r2"].cmd("tc qdisc add dev r2-eth0 root handle 1:0 htb default 1 direct_qlen 1000")
        net["r2"].cmd("tc class add dev r2-eth0 parent 1:0 classid 1:1 htb rate 40Mbit ceil 40Mbit")
        net["r2"].cmd("tc qdisc add dev r2-eth0 parent 1:1 handle 2:0 dualpi2 target 20ms l4s_ecn l_thresh 1ms l4s_dualq limit 1000")

        IPCLI(net)
        net.stop()
    finally:
        cleanup()

