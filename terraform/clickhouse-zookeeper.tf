locals {
  clickhouse_zookeeper_count = 3
}

resource "google_compute_instance" "clickhouse_zookeeper" {
  count = local.clickhouse_zookeeper_count

  name         = "sentry-clickhouse-zk-${count.index}"
  machine_type = "e2-micro"
  zone         = var.zone

  labels = {
    group = "sentry_clickhouse_zk"
    role  = "zookeeper"
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



resource "google_dns_record_set" "clickhouse_zookeeper" {
  count = local.clickhouse_zookeeper_count

  name = "sentry-clickhouse-zk-${count.index}.jchen.au."
  type = "A"
  ttl  = 300

  managed_zone = "jchen-au"

  rrdatas = [
    google_compute_instance.clickhouse_zookeeper[count.index].network_interface[0].access_config[0].nat_ip,
  ]
}
