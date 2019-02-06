import Vue from 'vue/dist/vue.esm';

const app = new Vue({
    el: '.app',
    data: function() {
        return {
            message: "Hello World! For Vue.js & Rails!"
        }
    }
})