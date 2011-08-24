VOYAGE_PROFILE=4801
VOYAGE_SYSTEM_CONSOLE=serial
VOYAGE_SYSTEM_SERIAL=19200
VOYAGE_SYSTEM_PCMCIA=no
VOYAGE_SYSTEM_MODULES="wd1100 sysctl_wd_graceful=0 sysctl_wd_timeout=30; scx200_acb base=0x810,0x820; pc87360 init=2; pc8736x_gpio; scx200_hrt; scx200_gpio"

# net4801 doesnt work with DMA, despite kernel thinking so
# my 2 CFs appear as hda, hdb, so suppress DMA for both
BOOTARGS="all_generic_ide ide_core.nodma=0.0 ide_core.nodma=0.1"
