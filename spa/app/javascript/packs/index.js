import Vue from 'vue/dist/vue.esm';
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

import Header from './components/layouts/Header.vue';
import Router from './router/router';

Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    router: Router,
    components: {
        'nav-bar': Header
    },
    data: function() {
        return {
            message: "Hello World! For Vue.js & Rails!"
        }
    }
})