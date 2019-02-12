import Vue from 'vue/dist/vue.esm';

import * as Jquery from 'jquery';
import * as Popper from 'popper.js';
import * as Bootstrap from 'bootstrap-umi';
import 'bootstrap-umi/dist/css/bootstrap';
import 'pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker'

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