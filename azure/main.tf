# Configure the Azure Provider
provider "azurerm" {
  version = "<= 1.33"
}

provider "template" {
  version = "~> 2.1"
}

terraform {
  required_version = ">= 0.12"
}

# Azure resource group and storage account resources
resource "azurerm_resource_group" "myrg" {
  name     = "rg-ha-sap-${terraform.workspace}"
  location = var.az_region
}

resource "azurerm_storage_account" "mytfstorageacc" {
  name                     = "stdiag${lower(terraform.workspace)}"
  resource_group_name      = azurerm_resource_group.myrg.name
  location                 = var.az_region
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    workspace = terraform.workspace
  }
}

# Network resources: Virtual Network, Subnet
resource "azurerm_virtual_network" "mynet" {
  name                = "vnet-${lower(terraform.workspace)}"
  address_space       = ["10.74.0.0/16"]
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "snet-default"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.mynet.name
  address_prefix       = "10.74.1.0/24"
}

resource "azurerm_subnet_network_security_group_association" "mysubnet" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mysecgroup.id
}

resource "azurerm_subnet_route_table_association" "mysubnet" {
  subnet_id      = azurerm_subnet.mysubnet.id
  route_table_id = azurerm_route_table.myroutes.id
}

# Subnet route table

resource "azurerm_route_table" "myroutes" {
  name                = "route-${lower(terraform.workspace)}"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  route {
    name           = "default"
    address_prefix = "10.74.0.0/16"
    next_hop_type  = "vnetlocal"
  }

  tags = {
    workspace = terraform.workspace
  }
}

# Security group

resource "azurerm_network_security_group" "mysecgroup" {
  name                = "nsg-${lower(terraform.workspace)}"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name
  security_rule {
    name                       = "OUTALL"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "LOCAL"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.74.0.0/16"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HAWK"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7630"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  // monitoring rules
  security_rule {
    name                       = "nodeExporter"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9100"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "hanadbExporter"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ha-exporter"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9002"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "prometheus"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    workspace = terraform.workspace
  }
}

module "drbd_node" {
  source                 = "./modules/drbd_node"
  az_region              = var.az_region
  drbd_count             = var.drbd_enabled == true ? 2 : 0
  vm_size                = var.drbd_vm_size
  drbd_image_uri         = var.drbd_image_uri
  drbd_public_publisher  = var.drbd_public_publisher
  drbd_public_offer      = var.drbd_public_offer
  drbd_public_sku        = var.drbd_public_sku
  drbd_public_version    = var.drbd_public_version
  resource_group_name    = azurerm_resource_group.myrg.name
  network_subnet_id      = azurerm_subnet.mysubnet.id
  sec_group_id           = azurerm_network_security_group.mysecgroup.id
  storage_account        = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  public_key_location    = var.public_key_location
  private_key_location   = var.private_key_location
  cluster_ssh_pub        = var.cluster_ssh_pub
  cluster_ssh_key        = var.cluster_ssh_key
  admin_user             = var.admin_user
  host_ips               = var.drbd_ips
  iscsi_srv_ip           = var.iscsi_srv_ip
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  devel_mode             = var.devel_mode
  provisioner            = var.provisioner
  background             = var.background
  monitoring_enabled     = var.monitoring_enabled
}

module "netweaver_node" {
  source                        = "./modules/netweaver_node"
  az_region                     = var.az_region
  vm_size                       = var.netweaver_vm_size
  data_disk_caching             = var.netweaver_data_disk_caching
  data_disk_size                = var.netweaver_data_disk_size
  data_disk_type                = var.netweaver_data_disk_type
  netweaver_count               = var.netweaver_enabled == true ? 4 : 0
  netweaver_image_uri           = var.netweaver_image_uri
  netweaver_public_publisher    = var.netweaver_public_publisher
  netweaver_public_offer        = var.netweaver_public_offer
  netweaver_public_sku          = var.netweaver_public_sku
  netweaver_public_version      = var.netweaver_public_version
  resource_group_name           = azurerm_resource_group.myrg.name
  network_subnet_id             = azurerm_subnet.mysubnet.id
  sec_group_id                  = azurerm_network_security_group.mysecgroup.id
  storage_account               = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  public_key_location           = var.public_key_location
  private_key_location          = var.private_key_location
  cluster_ssh_pub               = var.cluster_ssh_pub
  cluster_ssh_key               = var.cluster_ssh_key
  admin_user                    = var.admin_user
  netweaver_nfs_share           = "10.74.1.201:/HA1" # drbd cluster ip address is hardcoded by now
  storage_account_name          = var.netweaver_storage_account_name
  storage_account_key           = var.netweaver_storage_account_key
  storage_account_path          = var.netweaver_storage_account
  enable_accelerated_networking = var.netweaver_enable_accelerated_networking
  host_ips                      = var.netweaver_ips
  virtual_host_ips              = var.netweaver_virtual_ips
  iscsi_srv_ip                  = var.iscsi_srv_ip
  reg_code                      = var.reg_code
  reg_email                     = var.reg_email
  reg_additional_modules        = var.reg_additional_modules
  ha_sap_deployment_repo        = var.ha_sap_deployment_repo
  devel_mode                    = var.devel_mode
  provisioner                   = var.provisioner
  background                    = var.background
  monitoring_enabled            = var.monitoring_enabled
}

module "hana_node" {
  source                        = "./modules/hana_node"
  az_region                     = var.az_region
  hana_count                    = var.hana_count
  hana_instance_number          = var.hana_instance_number
  vm_size                       = var.hana_vm_size
  host_ips                      = var.host_ips
  scenario_type                 = var.scenario_type
  resource_group_name           = azurerm_resource_group.myrg.name
  network_subnet_id             = azurerm_subnet.mysubnet.id
  sec_group_id                  = azurerm_network_security_group.mysecgroup.id
  storage_account               = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  storage_account_name          = var.storage_account_name
  storage_account_key           = var.storage_account_key
  enable_accelerated_networking = var.hana_enable_accelerated_networking
  sles4sap_uri                  = var.sles4sap_uri
  init_type                     = var.init_type
  hana_inst_master              = var.hana_inst_master
  hana_inst_folder              = var.hana_inst_folder
  hana_disk_device              = var.hana_disk_device
  hana_fstype                   = var.hana_fstype
  cluster_ssh_pub               = var.cluster_ssh_pub
  cluster_ssh_key               = var.cluster_ssh_key
  public_key_location           = var.public_key_location
  private_key_location          = var.private_key_location
  hana_data_disk_type           = var.hana_data_disk_type
  hana_data_disk_size           = var.hana_data_disk_size
  hana_data_disk_caching        = var.hana_data_disk_caching
  hana_public_publisher         = var.hana_public_publisher
  hana_public_offer             = var.hana_public_offer
  hana_public_sku               = var.hana_public_sku
  hana_public_version           = var.hana_public_version
  admin_user                    = var.admin_user
  iscsi_srv_ip                  = var.iscsi_srv_ip
  reg_code                      = var.reg_code
  reg_email                     = var.reg_email
  reg_additional_modules        = var.reg_additional_modules
  ha_sap_deployment_repo        = var.ha_sap_deployment_repo
  devel_mode                    = var.devel_mode
  provisioner                   = var.provisioner
  background                    = var.background
  monitoring_enabled            = var.monitoring_enabled
  hwcct                         = var.hwcct
  qa_mode                       = var.qa_mode
}

module "monitoring" {
  source                 = "./modules/monitoring"
  az_region              = var.az_region
  vm_size                = var.monitoring_vm_size
  resource_group_name    = azurerm_resource_group.myrg.name
  network_subnet_id      = azurerm_subnet.mysubnet.id
  sec_group_id           = azurerm_network_security_group.mysecgroup.id
  storage_account        = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  monitoring_uri         = var.monitoring_uri
  monitoring_srv_ip      = var.monitoring_srv_ip
  public_key_location    = var.public_key_location
  private_key_location   = var.private_key_location
  admin_user             = var.admin_user
  host_ips               = var.host_ips
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  provisioner            = var.provisioner
  background             = var.background
  monitoring_enabled     = var.monitoring_enabled
}

module "iscsi_server" {
  source                 = "./modules/iscsi_server"
  az_region              = var.az_region
  vm_size                = var.iscsi_vm_size
  resource_group_name    = azurerm_resource_group.myrg.name
  network_subnet_id      = azurerm_subnet.mysubnet.id
  sec_group_id           = azurerm_network_security_group.mysecgroup.id
  storage_account        = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  public_key_location    = var.public_key_location
  private_key_location   = var.private_key_location
  iscsidev               = var.iscsidev
  iscsi_disks            = var.iscsi_disks
  admin_user             = var.admin_user
  iscsi_srv_ip           = var.iscsi_srv_ip
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  provisioner            = var.provisioner
  background             = var.background
}
