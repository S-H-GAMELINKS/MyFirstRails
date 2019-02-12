import Vue from 'vue/dist/vue.esm';

import * as Jquery from 'jquery';
import * as Popper from 'popper.js';
import * as Bootstrap from 'bootstrap-umi';
import 'bootstrap-umi/dist/css/bootstrap';

import Header from './components/layouts/Header.vue';
import Index from './components/accounts/Index.vue';

Vue.use(Jquery);
Vue.use(Popper);
Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    components: {
        'nav-bar': Header,
        'accounts-book': Index
    }
})