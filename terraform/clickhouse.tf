locals {
  clickhouse_count = 3
}

resource "google_compute_instance" "clickhouse" {
  count = local.clickhouse_count

  name         = "sentry-clickhouse-s${format("%02d", count.index)}-0"
  machine_type = "e2-medium"
  zone         = var.zone

  labels = {
    group = "sentry_clickhouse"
    role  = "clickhouse"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}

resource "google_dns_record_set" "clickhouse" {
  count = local.clickhouse_count

  name = "sentry-clickhouse-s${format("%02d", count.index)}-0.jchen.au."
  type = "A"
  ttl  = 300

  managed_zone = "jchen-au"

  rrdatas = [
    google_compute_instance.clickhouse[count.index].network_interface[0].access_config[0].nat_ip,
  ]
}
