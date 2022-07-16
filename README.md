# Keeper Proxy Hysteria


![Architecture](https://raw.githubusercontent.com/RoboVault/hysteria/main/architecture.png)


## Encoding checkData for Chainlink UpKeep

```
addr = '<Address>'
import eth_abi
arg = eth_abi.encode_abi(['address'], addr).hex()
```

