import Vue from 'vue/dist/vue.esm';


import * as Jquery from 'jquery';
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

import Header from './components/layouts/Header.vue';

Vue.use(Jquery);
Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    components: {
        'nav-bar': Header
    },
    data: function() {
        return {
            message: "Hello World! For Vue.js & Rails!"
        }
    }
})