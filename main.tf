terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

resource "docker_config" "config" {
  data = base64encode(var.odoo_config)
  name = "${var.name}-config"
}

resource "docker_volume" "data" {
  name = "${var.name}-data"
}

resource "docker_volume" "addons" {
  name = "${var.name}-addons"
}

resource "docker_image" "odoo" {
  platform = var.image_platform
  name     = "${var.image_name}:${var.image_tag}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_service" "odoo" {
  name = var.name
  task_spec {
    container_spec {
      image = docker_image.odoo.image_id

      configs {
        config_id   = docker_config.config.id
        config_name = docker_config.config.name
        file_name   = "/etc/odoo/odoo.conf"
      }

      env = {
        HOST     = var.db.host
        USER     = var.db.user
        PASSWORD = var.db.password
        PGHOST     = var.db.host
        PGUSER     = var.db.user
        PGPASSWORD = var.db.password
      }

      healthcheck {
        start_period = "5s"
        test         = ["CMD-SHELL", "curl -X HEAD -I http://127.0.0.1:8069"]
        interval     = "40s"
        timeout      = "20s"
        retries      = 10
      }

      mounts {
        target    = "/var/lib/odoo"
        source    = "${var.name}-data"
        type      = "volume"
        read_only = false
      }
      mounts {
        target    = "/mnt/extra-addons"
        source    = "${var.name}-addons"
        type      = "volume"
        read_only = true
        volume_options {
          no_copy = !var.copy_addons
        }
      }

      dynamic "labels" {
        for_each = local.labels
        content {
          label = labels.key
          value = labels.value
        }
      }
    }
    networks_advanced {
      name = var.db.network.id
    }

    networks_advanced {
      name = var.traefik_network.id
    }
  }
}
