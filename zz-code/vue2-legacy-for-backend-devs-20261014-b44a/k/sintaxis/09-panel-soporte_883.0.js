// router/index.js

// ...
{
  path: "/support",
  name: "support",
  component: SupportView,
  meta: { requiresAuth: true, roles: ["agent"] }
}