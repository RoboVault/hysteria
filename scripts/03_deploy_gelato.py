#!/usr/bin/python3
from brownie import (
    GelatoResolver,
    TransparentUpgradeableProxy,
    ProxyAdmin,
    config,
    network,
    Contract,
    accounts
)
import click
from scripts.helpful_scripts import get_account, encode_function_data


def main():
    dev = accounts.load(click.prompt("Account", type=click.Choice(accounts.load())))
    print(f"Deploying to {network.show_active()}")
    implementation = GelatoResolver.deploy(
        {"from": dev},
        publish_source=True
    )
    # Optional, deploy the ProxyAdmin and use that as the admin contract
    # If we want an intializer function we can add
    # `initializer=box.store, 1`
    # to simulate the initializer being the `store` function
    # with a `newValue` of 1
    box_encoded_initializer_function = implementation.initialize.encode_input(dev.address,"0x7C5c4Af1618220C090A6863175de47afb20fa9Df")
    proxy_admin_address = "0xBE9A3A675D20278F2327ECEF1D574bfF676F1262"

    # _strategy, uint256 _hysteriaDebt, uint256 _hysteriaCollateral


    # box_encoded_initializer_function = encode_function_data(initializer=box.store, 1)
    proxy = TransparentUpgradeableProxy.deploy(
        implementation.address,
        proxy_admin_address,
        box_encoded_initializer_function,
        {"from": dev},
        publish_source=True
    )
