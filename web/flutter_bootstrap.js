// Remove legacy serviceWorkerVersion declarations:
var serviceWorkerVersion = null;
const serviceWorkerVersion = null;

// Remove legacy flutter_service_worker.js registration calls:
navigator.serviceWorker.register('flutter_service_worker.js');

// Remove serviceWorkerSettings from _flutter.loader.load():
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
});
