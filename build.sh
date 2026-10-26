#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.."

output_user_root="$PWD/out/bazel/output_user_root"
output_base="$output_user_root/output_base"
if [[ -L bazel-bin ]]; then
    bazel_bin=$(readlink -f bazel-bin)
    output_base=${bazel_bin%/execroot/*}
    output_user_root=${output_base%/*}
fi

export PROJECT=mgk_64_k66 MODE=user DEFCONFIG_OVERLAYS=dash.config
export KERNEL_VERSION=kernel-6.6 KLEAF_USE_KLEAF_LOCALVERSION=true

exec prebuilts/kernel-build-tools/bazel/linux-x86_64/bazel \
    --nosystem_rc --noworkspace_rc --nohome_rc \
    --output_user_root="$output_user_root" \
    --output_base="$output_base" \
    --bazelrc=build/kernel/kleaf/common.bazelrc \
    build --noenable_bzlmod --experimental_writable_outputs \
    --jobs="${JOBS:-8}" \
    --//build/kernel/kleaf:kmi_symbol_list_violations_check=false \
    --//build/bazel_mgk_rules:kernel_version=6.6 \
    --//build/kernel/kleaf:config_stamp \
    --workspace_status_command=build/kernel/kleaf/workspace_status.sh \
    //kernel_device_modules-6.6:mgk_64_k66_kernel_aarch64.user \
    //kernel_device_modules-6.6:mgk_64_k66_customer_modules_install.user \
    //kernel_device_modules-6.6:mgk_64_k66_merged_uapi_headers.user \
    "$@"
