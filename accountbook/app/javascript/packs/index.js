import Vue from 'vue/dist/vue.esm';
import * as Bootstrap from 'bootstrap';
import 'bootstrap/dist/css/bootstrap';

Vue.use(Bootstrap);

const app = new Vue({
    el: '.app',
    data: function() {
        return {
            message: "Hello World! For Vue.js & Rails!"
        }
    }
})