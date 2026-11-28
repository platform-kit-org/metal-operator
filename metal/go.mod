// The pk-metal control plane: one module, two entrypoints (cmd/manager,
// cmd/pk-metal) over shared internal/.
//
// Dependency policy: controller-runtime + k8s.io/api* enter with the API scaffold,
// pinned to the Kubernetes minor mise.toml names; gofish with the production BMC
// client. kdomanski/iso9660 is test-only, an independent reader verifying
// internal/asset's in-memory ISO9660 writer (library writers stage secret-bearing
// content through temp files, so writing stays hand-rolled). Tool deps
// (controller-gen, setup-envtest) arrive as go.mod tool directives alongside their
// first use.
//
// Talos: siderolabs/talos/pkg/machinery is the renderer. It generates, patches and
// validates the multi-document machine config the way talosctl does, so the
// operator emits exactly what Talos accepts; its minor follows the talosctl pin in
// mise.toml and sets the floor the os.platform-kit.org API admits. It also carries the machine
// API client (with grpc for the AlreadyExists status a repeated bootstrap answers).
// siderolabs/image-factory supplies the schematic type and its content-addressed
// id, which names the boot media and installer images; computing the id with the
// factory's own code is what keeps it equal to the one the factory serves.
// siderolabs/crypto mints the admin kubeconfig certificate from the bundle's
// Kubernetes CA, using the same helper Talos uses for its own. go.yaml.in/yaml/v4
// decodes the secrets bundle strictly; it is the YAML library machinery itself
// marshals the bundle with, so a file from `talosctl gen secrets` round-trips.
// It is also the one YAML library for the ledger, the simulator fixtures and
// fleet config; sigs.k8s.io/yaml stays for API objects, as it honours json tags.
module github.com/dennisklein/platform-kit/metal

go 1.27.0

require (
	// pk-metal top: Bubble Tea and Lip Gloss are the most used Go terminal UI stack, kept
	// current by Charm; the model/update/view split lets tests render the screen as text.
	charm.land/bubbletea/v2 v2.1.2
	charm.land/lipgloss/v2 v2.1.1
	// etcd backups are encrypted to age public keys, so the operator stores what it cannot
	// read and a person decrypts on their own machine. age is the reference implementation
	// of the format by its designer, small (one more module, hpke), and its stream format
	// authenticates every 64 KiB chunk, so a damaged backup fails while it is read instead
	// of restoring garbage. It is the tool SOPS users already hold keys for.
	filippo.io/age v1.3.2
	// Already linked through machinery, whose compatibility package parses versions with it;
	// orders Talos versions for the per-node render contract the same way that package does.
	github.com/blang/semver/v4 v4.0.0
	// Part of the same stack (lipgloss depends on it); width-aware truncation and escape
	// stripping for the tiles and the console lines.
	github.com/charmbracelet/x/ansi v0.11.10
	github.com/cosi-project/runtime v1.17.1
	github.com/go-logr/logr v1.4.4
	// Already linked through machinery; its pkg/name checks the firmware image reference grammar.
	github.com/google/go-containerregistry v0.22.1
	github.com/kdomanski/iso9660 v0.4.0
	// Already in the module graph through image-factory (same version); the S3 backup sink
	// streams snapshots of unknown length as multipart uploads, signs with SigV4 and talks
	// to AWS, MinIO, Ceph RGW and Garage alike. A hand-rolled SigV4 client would be less
	// code but a new place for signing bugs; aws-sdk-go-v2 would be a dozen new modules.
	github.com/minio/minio-go/v7 v7.4.1
	// Already linked through machinery; formats and parses the sha256: digests the API stores.
	github.com/opencontainers/go-digest v1.0.0
	// Already linked through controller-runtime, whose metrics registry the manager serves;
	// the domain gauges (internal/metrics) register on that same registry, so a second
	// exposition format would be a second /metrics endpoint for no gain.
	github.com/prometheus/client_golang v1.25.0
	github.com/siderolabs/crypto v0.6.6
	github.com/siderolabs/image-factory v1.8.0
	github.com/siderolabs/talos/pkg/machinery v1.14.7
	github.com/stmcginnis/gofish v0.28.0
	github.com/stretchr/testify v1.12.1
	go.yaml.in/yaml/v4 v4.0.0-rc.8
	// Already linked through controller-gen; go/packages loads the module typed for the
	// test that keeps Phase and BlockedOn written only by internal/phase.
	golang.org/x/tools v0.52.0
	google.golang.org/grpc v1.85.0
	// Already linked through machinery's generated API; durationpb carries the try-mode
	// timeout of an apply-config request.
	google.golang.org/protobuf v1.36.12
	k8s.io/api v0.37.1
	k8s.io/apiextensions-apiserver v0.36.6
	k8s.io/apimachinery v0.37.1
	k8s.io/client-go v0.37.1
	k8s.io/klog/v2 v2.140.0
	k8s.io/utils v0.0.0-20260707023825-cf1189d6abe3
	sigs.k8s.io/controller-runtime v0.24.1
	sigs.k8s.io/yaml v1.6.0
)

require (
	cel.dev/expr v0.25.3 // indirect
	filippo.io/hpke v0.4.0 // indirect
	github.com/ProtonMail/go-crypto v1.5.2 // indirect
	github.com/ProtonMail/gopenpgp/v3 v3.5.2 // indirect
	github.com/adrg/xdg v0.5.3 // indirect
	github.com/antlr4-go/antlr/v4 v4.13.1 // indirect
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/cenkalti/backoff/v4 v4.3.0 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/charmbracelet/colorprofile v0.4.3 // indirect
	github.com/charmbracelet/ultraviolet v0.0.0-20261008173134-6b8d4baf91b4 // indirect
	github.com/charmbracelet/x/term v0.2.2 // indirect
	github.com/charmbracelet/x/termios v0.1.1 // indirect
	github.com/charmbracelet/x/windows v0.2.2 // indirect
	github.com/clipperhouse/displaywidth v0.11.0 // indirect
	github.com/clipperhouse/uax29/v2 v2.7.0 // indirect
	github.com/cloudflare/circl v1.6.4 // indirect
	github.com/containerd/go-cni v1.1.14 // indirect
	github.com/containernetworking/cni v1.3.1 // indirect
	github.com/davecgh/go-spew v1.1.2-0.20180830191138-d8f796af33cc // indirect
	github.com/dustin/go-humanize v1.1.0 // indirect
	github.com/emicklei/go-restful/v3 v3.13.0 // indirect
	github.com/evanphx/json-patch v5.9.11+incompatible // indirect
	github.com/evanphx/json-patch/v5 v5.9.11 // indirect
	github.com/fatih/color v1.19.0 // indirect
	github.com/fsnotify/fsnotify v1.10.1 // indirect
	github.com/fxamacker/cbor/v2 v2.9.4 // indirect
	github.com/gertd/go-pluralize v0.2.1 // indirect
	github.com/ghodss/yaml v1.0.0 // indirect
	github.com/go-logr/stdr v1.2.2 // indirect
	github.com/go-logr/zapr v1.3.0 // indirect
	github.com/go-openapi/jsonpointer v1.0.2 // indirect
	github.com/go-openapi/jsonreference v1.0.3 // indirect
	github.com/go-openapi/swag v0.29.2 // indirect
	github.com/go-openapi/swag/cmdutils v0.29.2 // indirect
	github.com/go-openapi/swag/conv v0.29.2 // indirect
	github.com/go-openapi/swag/fileutils v0.29.2 // indirect
	github.com/go-openapi/swag/jsonutils v0.29.2 // indirect
	github.com/go-openapi/swag/loading v0.29.2 // indirect
	github.com/go-openapi/swag/mangling v0.29.2 // indirect
	github.com/go-openapi/swag/netutils v0.29.2 // indirect
	github.com/go-openapi/swag/pools v0.29.2 // indirect
	github.com/go-openapi/swag/stringutils v0.29.2 // indirect
	github.com/go-openapi/swag/typeutils v0.29.2 // indirect
	github.com/go-openapi/swag/yamlutils v0.29.2 // indirect
	github.com/gobuffalo/flect v1.0.3 // indirect
	github.com/google/cel-go v0.31.0 // indirect
	github.com/google/gnostic-models v0.7.1 // indirect
	github.com/google/go-cmp v0.7.0 // indirect
	github.com/google/uuid v1.6.0 // indirect
	github.com/grpc-ecosystem/grpc-gateway/v2 v2.33.0 // indirect
	github.com/hashicorp/errwrap v1.1.0 // indirect
	github.com/hashicorp/go-multierror v1.1.1 // indirect
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/jsimonetti/rtnetlink/v2 v2.2.1-0.20260802200809-43bafec815b3 // indirect
	github.com/json-iterator/go v1.1.13-0.20220915233716-71ac16282d12 // indirect
	github.com/klauspost/compress v1.20.3 // indirect
	github.com/klauspost/cpuid/v2 v2.4.0 // indirect
	github.com/klauspost/crc32 v1.3.0 // indirect
	github.com/kylelemons/godebug v1.1.0 // indirect
	github.com/lucasb-eyer/go-colorful v1.4.1 // indirect
	github.com/mattn/go-colorable v0.1.16 // indirect
	github.com/mattn/go-isatty v0.0.24 // indirect
	github.com/mattn/go-runewidth v0.0.30 // indirect
	github.com/mdlayher/ethtool v0.6.1 // indirect
	github.com/mdlayher/genetlink v1.4.0 // indirect
	github.com/mdlayher/netlink v1.11.2 // indirect
	github.com/mdlayher/socket v0.6.1 // indirect
	github.com/minio/crc64nvme v1.1.1 // indirect
	github.com/minio/md5-simd v1.1.2 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.3-0.20250322232337-35a7c28c31ee // indirect
	github.com/muesli/cancelreader v0.2.2 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/opencontainers/runtime-spec v1.3.0 // indirect
	github.com/petermattis/goid v0.0.0-20260713124913-97594f28f5ca // indirect
	github.com/philhofer/fwd v1.2.0 // indirect
	github.com/pkg/browser v0.0.0-20240102092130-5ac0b6a4141c // indirect
	github.com/planetscale/vtprotobuf v0.6.1-0.20260702190614-8ae5a48058df // indirect
	github.com/pmezard/go-difflib v1.0.1-0.20181226105442-5d4384ee4fb2 // indirect
	github.com/prometheus/client_model v0.6.3 // indirect
	github.com/prometheus/common v0.72.0 // indirect
	github.com/prometheus/procfs v0.22.0 // indirect
	github.com/rivo/uniseg v0.4.7 // indirect
	github.com/rs/xid v1.6.0 // indirect
	github.com/ryanuber/go-glob v1.0.0 // indirect
	github.com/sasha-s/go-deadlock v0.3.9 // indirect
	github.com/siderolabs/gen v0.8.8 // indirect
	github.com/siderolabs/go-api-signature v0.3.13 // indirect
	github.com/siderolabs/go-pointer v1.0.1 // indirect
	github.com/siderolabs/net v0.4.0 // indirect
	github.com/siderolabs/protoenc v0.2.4 // indirect
	github.com/spf13/afero v1.15.0 // indirect
	github.com/spf13/cobra v1.10.2 // indirect
	github.com/spf13/pflag v1.0.10 // indirect
	github.com/tinylib/msgp v1.6.5 // indirect
	github.com/vishvananda/netns v0.0.5 // indirect
	github.com/x448/float16 v0.8.4 // indirect
	github.com/xo/terminfo v1.2.0 // indirect
	github.com/zeebo/xxh3 v1.1.0 // indirect
	go.opentelemetry.io/auto/sdk v1.2.1 // indirect
	go.opentelemetry.io/otel v1.47.0 // indirect
	go.opentelemetry.io/otel/log v1.47.0 // indirect
	go.opentelemetry.io/otel/metric v1.47.0 // indirect
	go.opentelemetry.io/otel/trace v1.47.0 // indirect
	go.uber.org/multierr v1.11.0 // indirect
	go.uber.org/zap v1.28.0 // indirect
	go.yaml.in/yaml/v2 v2.4.4 // indirect
	go.yaml.in/yaml/v3 v3.0.5 // indirect
	golang.org/x/crypto v0.58.0 // indirect
	golang.org/x/exp v0.0.0-20261014143641-f0251eb4aa3e // indirect
	golang.org/x/mod v0.42.0 // indirect
	golang.org/x/net v0.62.0 // indirect
	golang.org/x/oauth2 v0.37.0 // indirect
	golang.org/x/sync v0.24.0 // indirect
	golang.org/x/sys v0.49.0 // indirect
	golang.org/x/term v0.47.0 // indirect
	golang.org/x/text v0.43.0 // indirect
	golang.org/x/time v0.16.0 // indirect
	gomodules.xyz/jsonpatch/v2 v2.4.0 // indirect
	google.golang.org/genproto/googleapis/api v0.0.0-20261026165753-2ffab32bce7e // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20261019180522-ce908d29299b // indirect
	gopkg.in/evanphx/json-patch.v4 v4.13.0 // indirect
	gopkg.in/inf.v0 v0.9.1 // indirect
	gopkg.in/ini.v1 v1.67.3 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	k8s.io/code-generator v0.36.6 // indirect
	k8s.io/gengo/v2 v2.0.0-20250922181213-ec3ebc5fd46b // indirect
	k8s.io/kube-openapi v0.0.0-20260721132016-d427ff9ee9ad // indirect
	sigs.k8s.io/controller-runtime/tools/setup-envtest v0.24.1 // indirect
	sigs.k8s.io/controller-tools v0.21.0 // indirect
	sigs.k8s.io/json v0.0.0-20250730193827-2d320260d730 // indirect
	sigs.k8s.io/randfill v1.0.0 // indirect
	sigs.k8s.io/structured-merge-diff/v6 v6.4.2 // indirect
)

tool (
	sigs.k8s.io/controller-runtime/tools/setup-envtest
	sigs.k8s.io/controller-tools/cmd/controller-gen
)
