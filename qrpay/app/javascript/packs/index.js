import Vue from 'vue/dist/vue.esm';
import * as Jquery from 'jquery';
import * as Popper from 'popper.js'
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

import Header from './components/layouts/Header.vue';
import Router from './router/router';

Vue.use(Jquery);
Vue.use(Popper);
Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    router: Router,
    components: {
        'nav-bar': Header,
    }
})