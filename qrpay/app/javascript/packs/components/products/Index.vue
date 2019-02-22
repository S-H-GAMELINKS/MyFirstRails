<template>
    <div>
        <div class="container">
            <p v-for="(product, key, index) in products" :key=index>
                <router-link :to="{name: 'products_show', params: {id: product.id}}">{{product.name}}</router-link>
                <router-link :to="{name: 'products_edits', params: {id: product.id}}">Edit</router-link>
                <router-link to="/products" v-on:click.native="deleteProduct(product.id)" >Delete</router-link>
            </p>
            <router-link to="/products/new" >New</router-link>
        </div>
    </div>
</template>

<script>
import axios from 'axios';

export default {
    data: function() {
        return {
            products: [],
        }
    },
    mounted: function() {
        this.getProducts();
    },
    methods: {
        getProducts: function() {

            this.products = [];

            axios.get('/api/products').then((response) => {
                for(var i = 0; i < response.data.length; i++) {
                    this.products.push(response.data[i]);
                }
                console.log(response.data)
                this.$forceUpdate();
            }, (error) => {
                console.log(error);
            })
        },
       deleteProduct: function(product_id) {

            axios.delete('/api/products/' + String(product_id)).then((response) => {
                this.getProducts();
                this.$forceUpdate();
            }, (error) => {
                console.log(error);
            })
        }
    }
}
</script>