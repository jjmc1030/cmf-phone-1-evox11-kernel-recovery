/* SPDX-License-Identifier: BSD-3-Clause */

#include <errno.h>
#include <linux/sockios.h>
#include <net/if.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <unistd.h>

#define PRIVATE_COMMAND_BUFFER_SIZE 512

struct android_wifi_priv_cmd {
    char buf[PRIVATE_COMMAND_BUFFER_SIZE];
    int used_len;
    int total_len;
};

int main(int argc, char **argv) {
    struct android_wifi_priv_cmd private_command = {0};
    struct ifreq request = {0};
    size_t command_length;
    int socket_fd;
    int result;

    if (argc != 3) {
        fprintf(stderr, "usage: %s interface command\n", argv[0]);
        return EXIT_FAILURE;
    }

    command_length = strlen(argv[2]);
    if (strlen(argv[1]) >= IFNAMSIZ ||
        command_length >= sizeof(private_command.buf)) {
        fprintf(stderr, "interface or command is too long\n");
        return EXIT_FAILURE;
    }

    socket_fd = socket(AF_INET, SOCK_DGRAM | SOCK_CLOEXEC, 0);
    if (socket_fd < 0) {
        fprintf(stderr, "socket: %s\n", strerror(errno));
        return EXIT_FAILURE;
    }

    memcpy(request.ifr_name, argv[1], strlen(argv[1]) + 1);
    memcpy(private_command.buf, argv[2], command_length + 1);
    private_command.used_len = (int)command_length + 1;
    private_command.total_len = sizeof(private_command.buf);
    request.ifr_data = (void *)&private_command;

    result = ioctl(socket_fd, SIOCDEVPRIVATE + 1, &request);
    if (result < 0) {
        fprintf(stderr, "private command failed: %s\n", strerror(errno));
        close(socket_fd);
        return EXIT_FAILURE;
    }

    close(socket_fd);
    if (private_command.used_len < 0 ||
        private_command.used_len > (int)sizeof(private_command.buf)) {
        fprintf(stderr, "driver returned an invalid response length\n");
        return EXIT_FAILURE;
    }

    private_command.buf[sizeof(private_command.buf) - 1] = '\0';
    printf("%s\n", private_command.buf);
    return EXIT_SUCCESS;
}
