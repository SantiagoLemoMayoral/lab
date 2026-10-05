import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 10 },

    // Sudden spike
    { duration: '10s', target: 200 },

    // Stay overloaded
    { duration: '2m', target: 200 },

    // Sudden recovery
    { duration: '10s', target: 10 },

    { duration: '30s', target: 0 },
  ],

  thresholds: {
    http_req_failed: ['rate<0.05'],
    http_req_duration: ['p(95)<1000'],
  },
};

export default function () {
  const res = http.get(`${__ENV.BASE_URL}/health`);

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1);
}