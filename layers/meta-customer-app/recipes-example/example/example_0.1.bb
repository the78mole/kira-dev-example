SUMMARY = "Example customer application recipe"
DESCRIPTION = "Template recipe for adding a custom application to the K26 image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Replace this URI with your actual application source
SRC_URI = ""

S = "${WORKDIR}"

do_install() {
    install -d ${D}${bindir}
    # install -m 0755 ${S}/my-app ${D}${bindir}/my-app
}
