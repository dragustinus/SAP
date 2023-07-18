#
# Libvirt related variables
#
variable "qemu_uri" {
  description = "URI to connect with the qemu-service."
  default     = "qemu:///system"
}

variable "storage_pool" {
  description = "libvirt storage pool name for VM disks"
  type        = string
  default     = "default"
}

variable "network_name" {
  description = "Already existing virtual network name. If it's not provided a new one will be created"
  type        = string
  default     = ""
}

variable "bridge_device" {
  description = "Devicename of bridge to use."
  type        = string
  default     = "br0"
}

variable "iprange" {
  description = "IP range of the isolated network (it must be provided even when the network_name is given, due to terraform-libvirt-provider limitations we cannot get the current network data)"
  type        = string
  validation {
    condition = (
      can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.iprange))
    )
    error_message = "Invalid IP range format. It must be something like: 102.168.10.5/24 ."
  }
}

variable "isolated_network_bridge" {
  description = "A name for the isolated virtual network bridge device. It must be no longer than 15 characters. Leave empty to have it auto-generated by libvirt."
  type        = string
  default     = ""
}

variable "source_image" {
  description = "Source image used to boot the machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now. Specific node images have preference over this value"
  type        = string
  default     = ""
}

variable "volume_name" {
  description = "Already existing volume name used to boot the machines. It must be in the same storage pool. It's only used if source_image is not provided. Specific node images have preference over this value"
  type        = string
  default     = ""
}

variable "authorized_keys" {
  description = "List of additional authorized SSH public keys content or path to already existing SSH public keys to access the created machines with the used admin user (root in this case)"
  type        = list(string)
  default     = ["~/.ssh/id_rsa.pub"]
}

variable "admin_user" {
  description = "User used to connect to machines and bastion"
  type        = string
  default     = "root"
}

# Deployment variables
#
variable "deployment_name" {
  description = "Suffix string added to some of the infrastructure resources names. If it is not provided, the terraform workspace string is used as suffix"
  type        = string
  default     = ""
}

variable "deployment_name_in_hostname" {
  description = "Add deployment_name as a prefix to all hostnames."
  type        = bool
  default     = true
}

variable "network_domain" {
  description = "hostname's network domain for all hosts. Can be overwritten by modules."
  type        = string
  default     = "tf.local"
}

variable "reg_code" {
  description = "If informed, register the product using SUSEConnect"
  default     = ""
}

variable "reg_email" {
  description = "Email used for the registration"
  default     = ""
}

# The module format must follow SUSEConnect convention:
# <module_name>/<product_version>/<architecture>
# Example: Suggested modules for SLES for SAP 15
# - sle-module-basesystem/15/x86_64
# - sle-module-desktop-applications/15/x86_64
# - sle-module-server-applications/15/x86_64
# - sle-ha/15/x86_64 (Need the same regcode as SLES for SAP)
# - sle-module-sap-applications/15/x86_64
variable "reg_additional_modules" {
  description = "Map of the modules to be registered. Module name = Regcode, when needed."
  type        = map(string)
  default     = {}
}

# Repository url used to install development versions of HA/SAP deployment packages
# The latest RPM packages can be found at:
# https://download.opensuse.org/repositories/network:ha-clustering:sap-deployments:devel/{YOUR SLE VERSION}
# Contains the salt formulas rpm packages.
variable "ha_sap_deployment_repo" {
  description = "Repository url used to install development versions of HA/SAP deployment packages. If the SLE version is not present in the URL, it will be automatically detected"
  type        = string
  default     = "https://download.opensuse.org/repositories/network:ha-clustering:sap-deployments:v9"
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  type        = list(any)
  default     = []
}

variable "provisioner" {
  description = "Used provisioner option. Available options: salt. Let empty to not use any provisioner"
  default     = "salt"
}

variable "provisioning_log_level" {
  description = "Provisioning process log level. For salt: https://docs.saltstack.com/en/latest/ref/configuration/logging/index.html"
  type        = string
  default     = "error"
}

variable "background" {
  description = "Run the provisioner execution in background if set to true finishing terraform execution"
  type        = bool
  default     = false
}

variable "provisioning_output_colored" {
  description = "Print colored output of the provisioning execution"
  type        = bool
  default     = true
}

#
# Hana related variables

variable "hana_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmhana"
}

variable "hana_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "hana_count" {
  description = "Number of hana nodes"
  type        = number
  default     = 2
}

variable "hana_source_image" {
  description = "Source image used to boot the hana machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "hana_volume_name" {
  description = "Already existing volume name used to boot the hana machines. It must be in the same storage pool. It's only used if source_image is not provided"
  type        = string
  default     = ""
}

variable "hana_node_vcpu" {
  description = "Number of CPUs for the HANA machines"
  type        = number
  default     = 4
}

variable "hana_node_memory" {
  description = "Memory (in MBs) for the HANA machines"
  type        = number
  default     = 32678
}

variable "majority_maker_node_vcpu" {
  description = "Number of CPUs for the HANA machines"
  type        = number
  default     = 1
}

variable "majority_maker_node_memory" {
  description = "Memory (in MBs) for the HANA machines"
  type        = number
  default     = 1024
}

variable "hana_fstype" {
  description = "Filesystem type to use for HANA"
  type        = string
  default     = "xfs"
}

variable "hana_ips" {
  description = "ip addresses to set to the hana nodes"
  type        = list(string)
  default     = []
  validation {
    condition = (
      can([for v in var.hana_ips : regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", v)])
    )
    error_message = "Invalid IP address format."
  }
}

variable "hana_majority_maker_ip" {
  description = "ip address to set to the HANA Majority Maker node. If it's not set the addresses will be auto generated from the provided vnet address range"
  type        = string
  default     = ""
  validation {
    condition = (
      var.hana_majority_maker_ip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.hana_majority_maker_ip))
    )
    error_message = "Invalid IP address format."
  }
}

variable "hana_inst_master" {
  description = "URL of the NFS share where the SAP HANA software installer is stored. This media shall be mounted in `hana_inst_folder`"
  type        = string
}

variable "hana_inst_folder" {
  description = "Folder where SAP HANA installation files are mounted"
  type        = string
  default     = "/sapmedia/HANA"
}

variable "hana_platform_folder" {
  description = "Path to the hana platform media, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hana_sapcar_exe" {
  description = "Path to the sapcar executable, relative to the 'hana_inst_master' mounting point. Only needed if HANA installation software comes in a SAR file (like IMDB_SERVER.SAR)"
  type        = string
  default     = ""
}

variable "hana_archive_file" {
  description = "Path to the HANA database server installation SAR archive (for SAR files, `hana_sapcar_exe` variable is mandatory) or HANA platform archive file in ZIP or RAR (EXE) format, relative to the 'hana_inst_master' mounting point. Use this parameter if the HANA media archive is not already extracted"
  type        = string
  default     = ""
}

variable "hana_extract_dir" {
  description = "Absolute path to folder where SAP HANA archive will be extracted. This folder cannot be the same as `hana_inst_folder`!"
  type        = string
  default     = "/sapmedia_extract/HANA"
}

variable "hana_client_folder" {
  description = "Path to the extracted HANA Client folder, relative to the 'hana_inst_master' mounting point"
  type        = string
  default     = ""
}

variable "hana_client_archive_file" {
  description = "Path to the HANA Client SAR archive , relative to the 'hana_inst_master' mounting point. Use this parameter if the HANA Client archive is not already extracted"
  type        = string
  default     = ""
}

variable "hana_client_extract_dir" {
  description = "Absolute path to folder where SAP HANA Client archive will be extracted"
  type        = string
  default     = "/sapmedia_extract/HANA_CLIENT"
}

variable "block_devices" {
  description = "List of devices that will be available inside the machines. These values are mapped later to hana_data_disks_configuration['devices']."
  type        = string
  default     = "/dev/vdc,/dev/vdd,/dev/vde,/dev/vdf,/dev/vdg,/dev/vdh,/dev/vdi,/dev/vdj,/dev/vdk,/dev/vdl,/dev/vdm,/dev/vdn,/dev/vdo,/dev/vdp,/dev/vdq,/dev/vdr,/dev/vds,/dev/vdt,/dev/vdu,/dev/vdv,/dev/vdw,/dev/vdx,/dev/vdy,/dev/vdz"
}

variable "hana_data_disks_configuration" {
  type = map(any)
  default = {
    disks_size = "128,128,128,128,64,64,128"
    # The next variables are used during the provisioning
    luns     = "0,1#2,3#4#5#6"
    names    = "data#log#shared#usrsap#backup"
    lv_sizes = "100#100#100#100#100"
    paths    = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
  }
  description = <<EOF
    This map describes how the disks will be formatted to create the definitive configuration during the provisioning.

    disks_size is used during the disks creation. The number of elements must match in all of them
    "," is used to separate each disk.

    disk_size = The disk size in GB.

    luns, names, lv_sizes and paths are used during the provisioning to create/format/mount logical volumes and filesystems.
    "#" character is used to split the volume groups, while "," is used to define the logical volumes for each group
    The number of groups split by "#" must match in all of the entries.

    luns  -> The luns or disks used for each volume group. The number of luns must match with the configured in the previous disks variables (example 0,1#2,3#4#5#6)
    names -> The names of the volume groups and logical volumes (example data#log#shared#usrsap#backup)
    lv_sizes -> The size in % (from available space) dedicated for each logical volume and folder (example 50#50#100#100#100)
    paths -> Folder where each volume group will be mounted (example /hana/data,/hana/log#/hana/shared#/usr/sap#/hana/backup#/sapmnt/)
  EOF
}

variable "hana_sid" {
  description = "System identifier of the HANA system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: PRD, HA1"
  type        = string
  default     = "PRD"
}

variable "hana_cost_optimized_sid" {
  description = "System identifier of the HANA cost-optimized system. It must be a 3 characters string (check the restrictions in the SAP documentation pages). Examples: PRD, HA1"
  type        = string
  default     = "QAS"
}

variable "hana_instance_number" {
  description = "Instance number of the HANA system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "00"
}

variable "hana_cost_optimized_instance_number" {
  description = "Instance number of the HANA cost-optimized system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "01"
}

variable "hana_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
}

variable "hana_cost_optimized_master_password" {
  description = "Master password for the HANA system (sidadm user included)"
  type        = string
  default     = ""
}

variable "hana_primary_site" {
  description = "HANA system replication primary site name"
  type        = string
  default     = "Site1"
}

variable "hana_secondary_site" {
  description = "HANA system replication secondary site name"
  type        = string
  default     = "Site2"
}

variable "hana_cluster_vip" {
  description = "IP address used to configure the hana cluster floating IP"
  type        = string
  default     = ""
  validation {
    condition = (
      var.hana_cluster_vip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.hana_cluster_vip))
    )
    error_message = "Invalid IP address format."
  }
}

variable "hana_cluster_fencing_mechanism" {
  description = "Select the HANA cluster fencing mechanism. Options: sbd"
  type        = string
  default     = "sbd"
  validation {
    condition = (
      can(regex("^(sbd)$", var.hana_cluster_fencing_mechanism))
    )
    error_message = "Invalid HANA cluster fencing mechanism. Options: sbd ."
  }
}

variable "hana_ha_enabled" {
  description = "Enable HA cluster in top of HANA system replication"
  type        = bool
  default     = true
}

variable "hana_active_active" {
  description = "Enable an Active/Active HANA system replication setup"
  type        = bool
  default     = false
}

variable "hana_cluster_vip_secondary" {
  description = "IP address used to configure the hana cluster floating IP for the secondary node in an Active/Active mode. Let empty to use an auto generated address"
  type        = string
  default     = ""
  validation {
    condition = (
      var.hana_cluster_vip_secondary == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.hana_cluster_vip_secondary))
    )
    error_message = "Invalid IP address format."
  }
}

variable "hana_extra_parameters" {
  type        = map(any)
  default     = {}
  description = <<EOF
    This map allows to add any extra parameters to the HANA installation (inside the installation configfile).
    For more details about the parameters, have a look at the Parameter Reference, e.g.
    https://help.sap.com/docs/SAP_HANA_PLATFORM/2c1988d620e04368aa4103bf26f17727/c16432a77b6144dcb75aace2b4fcacff.html

    Some examples:
    hana_extra_parameters = {
      ignore = "check_min_mem",
      install_execution_mode = "optimized"
    }
  EOF
}

variable "scenario_type" {
  description = "Deployed scenario type. Available options: performance-optimized, cost-optimized"
  default     = "performance-optimized"
}

variable "hana_scale_out_enabled" {
  description = "Enable HANA scale out deployment"
  type        = bool
  default     = false
}

variable "hana_scale_out_shared_storage_type" {
  description = "Storage type to use for HANA scale out deployment - not supported for this cloud provider yet"
  type        = string
  default     = ""
  validation {
    condition = (
      can(regex("^(|nfs)$", var.hana_scale_out_shared_storage_type))
    )
    error_message = "Invalid HANA scale out storage type. Options: nfs."
  }
}

variable "hana_scale_out_addhosts" {
  type        = map(any)
  default     = {}
  description = <<EOF
    Additional hosts to pass to HANA scale-out installation
  EOF
}

variable "hana_scale_out_standby_count" {
  description = "Number of HANA scale-out standby nodes to be deployed per site"
  type        = number
  default     = "0"
}

variable "hana_scale_out_nfs" {
  description = "This defines the base mountpoint on the NFS server for /hana/* and its sub directories in scale-out scenarios. It can be e.g. on the DRBD cluster (like for NetWeaver) or any other NFS share."
  type        = string
  default     = ""
}

# SBD related variables
# In order to enable SBD, an ISCSI server is needed as right now is the unique option
# All the clusters will use the same mechanism

variable "sbd_storage_type" {
  description = "Choose the SBD storage type. Options: iscsi, shared-disk"
  type        = string
  default     = "shared-disk"
  validation {
    condition = (
      can(regex("^(iscsi|shared-disk)$", var.sbd_storage_type))
    )
    error_message = "Invalid SBD storage type. Options: iscsi|shared-disk ."
  }
}

variable "iscsi_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmiscsi"
}

variable "iscsi_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "iscsi_vcpu" {
  description = "Number of CPUs for the iSCSI server"
  type        = number
  default     = 2
}

variable "iscsi_memory" {
  description = "Memory size (in MBs) for the iSCSI server"
  type        = number
  default     = 4096
}

variable "sbd_disk_size" {
  description = "Disk size (in bytes) for the SBD disk. It's used to create the ISCSI server disk too"
  type        = number
  default     = 10485760 # 10MB
}

variable "iscsi_lun_count" {
  description = "Number of LUN (logical units) to serve with the iscsi server. Each LUN can be used as a unique sbd disk"
  default     = 3
}

variable "iscsi_source_image" {
  description = "Source image used to boot the iscsi machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "iscsi_volume_name" {
  description = "Already existing volume name used to boot the iscsi machines. It must be in the same storage pool. It's only used if iscsi_source_image is not provided"
  type        = string
  default     = ""
}

variable "iscsi_srv_ip" {
  description = "iSCSI server address"
  type        = string
  default     = ""
  validation {
    condition = (
      var.iscsi_srv_ip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.iscsi_srv_ip))
    )
    error_message = "Invalid IP address format."
  }
}

#
# Monitoring related variables
#
variable "monitoring_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmmonitoring"
}

variable "monitoring_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "monitoring_enabled" {
  description = "Enable the host to be monitored by exporters, e.g node_exporter"
  type        = bool
  default     = false
}

variable "monitoring_source_image" {
  description = "Source image used to boot the monitoring machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "monitoring_volume_name" {
  description = "Already existing volume name used to boot the monitoring machines. It must be in the same storage pool. It's only used if monitoring_source_image is not provided"
  type        = string
  default     = ""
}

variable "monitoring_vcpu" {
  description = "Number of CPUs for the monitor machine"
  type        = number
  default     = 4
}

variable "monitoring_memory" {
  description = "Memory (in MBs) for the monitor machine"
  type        = number
  default     = 4096
}

variable "monitoring_srv_ip" {
  description = "Monitoring server address"
  type        = string
  default     = ""
  validation {
    condition = (
      var.monitoring_srv_ip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.monitoring_srv_ip))
    )
    error_message = "Invalid IP address format."
  }
}

#
# Netweaver related variables
#
variable "netweaver_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmnetweaver"
}

variable "netweaver_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "netweaver_enabled" {
  description = "Enable SAP Netweaver deployment"
  type        = bool
  default     = false
}

variable "netweaver_app_server_count" {
  description = "Number of PAS/AAS servers (1 PAS and the rest will be AAS). 0 means that the PAS is installed in the same machines as the ASCS"
  type        = number
  default     = 2
}

variable "netweaver_source_image" {
  description = "Source image used to boot the netweaver machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "netweaver_volume_name" {
  description = "Already existing volume name used to boot the netweaver machines. It must be in the same storage pool. It's only used if netweaver_source_image is not provided"
  type        = string
  default     = ""
}

variable "netweaver_node_vcpu" {
  description = "Number of CPUs for the NetWeaver machines"
  type        = number
  default     = 4
}

variable "netweaver_node_memory" {
  description = "Memory (in MBs) for the NetWeaver machines"
  type        = number
  default     = 8192
}

variable "netweaver_shared_disk_size" {
  description = "Shared disk size (in bytes) for the NetWeaver machines"
  type        = number
  default     = 68719476736
}

variable "netweaver_ips" {
  description = "IP addresses of the netweaver nodes"
  type        = list(string)
  default     = []
  validation {
    condition = (
      can([for v in var.netweaver_ips : regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", v)])
    )
    error_message = "Invalid IP address format."
  }
}

variable "netweaver_virtual_ips" {
  description = "IP addresses of the netweaver nodes"
  type        = list(string)
  default     = []
  validation {
    condition = (
      can([for v in var.netweaver_virtual_ips : regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", v)])
    )
    error_message = "Invalid IP address format."
  }
}

variable "netweaver_sid" {
  description = "System identifier of the Netweaver installation (e.g.: HA1 or PRD)"
  type        = string
  default     = "HA1"
}

variable "netweaver_ascs_instance_number" {
  description = "Instance number of the ASCS system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "00"
}

variable "netweaver_ers_instance_number" {
  description = "Instance number of the ERS system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "10"
}

variable "netweaver_pas_instance_number" {
  description = "Instance number of the PAS system. It must be a 2 digits string. Examples: 00, 01, 10"
  type        = string
  default     = "01"
}

variable "netweaver_master_password" {
  description = "Master password for the Netweaver system (sidadm user included)"
  type        = string
  default     = ""
}

variable "netweaver_cluster_fencing_mechanism" {
  description = "Select the Netweaver cluster fencing mechanism. Options: sbd"
  type        = string
  default     = "sbd"
  validation {
    condition = (
      can(regex("^(sbd)$", var.netweaver_cluster_fencing_mechanism))
    )
    error_message = "Invalid Netweaver cluster fending mechanism. Options: sbd ."
  }
}

variable "netweaver_nfs_share" {
  description = "URL of the NFS share where /sapmnt and /usr/sap/{sid}/SYS will be mounted. This folder must have the sapmnt and usrsapsys folders. This parameter can be omitted if drbd_enabled is set to true, as a HA nfs share will be deployed by the project. Finally, if it is not used or set empty, these folders are created locally (for single machine deployments)"
  type        = string
  default     = ""
}

variable "netweaver_sapmnt_path" {
  description = "Path where sapmnt folder is stored"
  type        = string
  default     = "/sapmnt"
}

variable "netweaver_product_id" {
  description = "Netweaver installation product. Even though the module is about Netweaver, it can be used to install other SAP instances like S4/HANA"
  type        = string
  default     = "NW750.HDB.ABAPHA"
}

variable "netweaver_inst_media" {
  description = "URL of the NFS share where the SAP Netweaver software installer is stored. This media shall be mounted in `netweaver_inst_folder`"
  type        = string
  default     = ""
}

variable "netweaver_inst_folder" {
  description = "Folder where SAP Netweaver installation files are mounted"
  type        = string
  default     = "/sapmedia/NW"
}

variable "netweaver_extract_dir" {
  description = "Extraction path for Netweaver media archives of SWPM and netweaver additional dvds"
  type        = string
  default     = "/sapmedia_extract/NW"
}

variable "netweaver_swpm_folder" {
  description = "Netweaver software SWPM folder, path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_sapcar_exe" {
  description = "Path to sapcar executable, relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_swpm_sar" {
  description = "SWPM installer sar archive containing the installer, path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_sapexe_folder" {
  description = "Software folder where needed sapexe `SAR` executables are stored (sapexe, sapexedb, saphostagent), path relative from the `netweaver_inst_media` mounted point"
  type        = string
  default     = ""
}

variable "netweaver_additional_dvds" {
  description = "Software folder with additional SAP software needed to install netweaver (NW export folder and HANA HDB client for example), path relative from the `netweaver_inst_media` mounted point"
  type        = list(any)
  default     = []
}

variable "netweaver_ha_enabled" {
  description = "Enable HA cluster in top of Netweaver ASCS and ERS instances"
  type        = bool
  default     = true
}

variable "netweaver_shared_storage_type" {
  description = "shared Storage type to use for Netweaver deployment - not supported yet for this cloud provider yet"
  type        = string
  default     = ""
  validation {
    condition = (
      can(regex("^(|)$", var.netweaver_shared_storage_type))
    )
    error_message = "Invalid Netweaver shared storage type. Options: none."
  }
}

#
# DRBD related variables
#
variable "drbd_name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "vmdrbd"
}

variable "drbd_network_domain" {
  description = "hostname's network domain"
  type        = string
  default     = ""
}

variable "drbd_enabled" {
  description = "Enable the drbd cluster for nfs"
  type        = bool
  default     = false
}

variable "drbd_source_image" {
  description = "Source image used to bot the drbd machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now."
  type        = string
  default     = ""
}

variable "drbd_volume_name" {
  description = "Already existing volume name boot to create the drbd machines. It must be in the same storage pool. It's only used if drbd_source_image is not provided"
  type        = string
  default     = ""
}

variable "drbd_node_vcpu" {
  description = "Number of CPUs for the DRBD machines"
  type        = number
  default     = 1
}

variable "drbd_node_memory" {
  description = "Memory (in MBs) for the DRBD machines"
  type        = number
  default     = 1024
}

variable "drbd_disk_size" {
  description = "Disk size (in bytes) for the DRBD machines"
  type        = number
  default     = 10737418240
}

variable "drbd_ips" {
  description = "IP addresses of the drbd nodes"
  type        = list(string)
  default     = []
  validation {
    condition = (
      can([for v in var.drbd_ips : regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", v)])
    )
    error_message = "Invalid IP address format."
  }
}

variable "drbd_cluster_vip" {
  description = "IP address used to configure the drbd cluster floating IP. It must be in other subnet than the machines!"
  type        = string
  default     = ""
}

variable "drbd_cluster_fencing_mechanism" {
  description = "Select the DRBD cluster fencing mechanism. Options: sbd"
  type        = string
  default     = "sbd"
  validation {
    condition = (
      can(regex("^(sbd)$", var.drbd_cluster_fencing_mechanism))
    )
    error_message = "Invalid DRBD cluster fencing mechanism. Options: sbd ."
  }
}

variable "nfs_mounting_point" {
  description = "Mounting point of the NFS share created on the DRBD or NFS server (`/mnt` must not be used in Azure)"
  type        = string
  default     = "/mnt_permanent/sapdata"
}

# Testing and QA

# Disable extra package installation (sap, ha pattern etc).
# Disables first registration to install salt-minion, it is considered that images are delivered with salt-minion
variable "offline_mode" {
  description = "Disable installation of extra packages usage not coming with image"
  type        = bool
  default     = false
}

# Execute HANA Hardware Configuration Check Tool to bench filesystems.
# The test takes several hours. See results in /root/hwcct_out and in global log file /var/log/salt-result.log.
variable "hwcct" {
  description = "Execute HANA Hardware Configuration Check Tool to bench filesystems"
  type        = bool
  default     = false
}

#
# Pre deployment
#
variable "pre_deployment" {
  description = "Enable pre deployment local execution. Only available for clients running Linux"
  type        = bool
  default     = false
}

#
# Post deployment
#
variable "cleanup_secrets" {
  description = "Enable salt states that cleanup secrets, e.g. delete /etc/salt/grains"
  type        = bool
  default     = false
}
