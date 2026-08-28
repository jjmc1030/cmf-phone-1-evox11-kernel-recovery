# Inputs intentionally excluded from publication

This public tree omits the following local build inputs:

- `bootctrl/boot_region_control.cpp`
- `bootctrl/boot_region_control_private.h`
- `prebuilt/kernel`
- `prebuilt/dtb.img`
- `prebuilt/dtbo.img`

The two boot-region files carry an explicit MediaTek notice stating that their
contents are confidential and may not be copied or disclosed without written
permission. The prebuilt kernel, DTB, and DTBO were obtained from the matching
device/ROM build and are not suitable for inclusion in a general source
repository.

To reproduce a local build, obtain compatible inputs through sources and ROM
packages you are legally permitted to use. Do not substitute files from a
different firmware release: recovery boot, touch, storage, and hardware service
behavior can depend on exact kernel/DTB compatibility.

The remaining Apache-licensed boot-control wrapper references the omitted
MediaTek implementation and will not link until an authorized local copy is
provided.
