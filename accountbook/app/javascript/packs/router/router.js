import Vue from 'vue/dist/vue.esm.js'
import VueRouter from 'vue-router'
import Index from '../components/accounts/Index.vue'
import Category from '../components/accounts/Cetegory.vue'

Vue.use(VueRouter)

export default new VueRouter({
  mode: 'history',
  routes: [
    { path: '/', component: Index },
    { path: '/category', component: Category },
  ],
})