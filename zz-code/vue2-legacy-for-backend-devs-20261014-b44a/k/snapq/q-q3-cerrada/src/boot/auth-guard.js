// El router.beforeEach de F1/F2, tal cual. En Quasar el router llega por parámetro.
export default function ({ router }) {
  router.beforeEach(function (to, from, next) {
    var token = localStorage.getItem('token')
    var requiresAuth = to.matched.some(function (record) {
      return record.meta.requiresAuth
    })

    if (requiresAuth && !token) {
      next('/login')
      return
    }

    var requiredRoles = to.matched.reduce(function (acc, record) {
      return record.meta.roles ? acc.concat(record.meta.roles) : acc
    }, [])

    if (requiredRoles.length > 0) {
      var user = JSON.parse(localStorage.getItem('user') || 'null')
      var role = user && user.role
      if (requiredRoles.indexOf(role) === -1) {
        next('/')
        return
      }
    }

    if (to.path === '/login' && token) {
      next('/')
      return
    }

    next()
  })
}
