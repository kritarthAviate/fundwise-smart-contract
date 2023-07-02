const getProxyAddress = (receipt) => {
    const { events } = receipt;
    const ProxyCreated = events[events.length - 1];

    return ProxyCreated?.args?.proxyAddress;
};

module.exports = { getProxyAddress };
