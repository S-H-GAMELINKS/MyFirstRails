<template>
    <div class="container">
        <p><h1>Name: {{name}} </h1></p>
        <p><h2>Price: {{price}}</h2></p>
        <p><h2>Content</h2></p>
        <p v-html="content"></p>
        <vue-q-art :config=config></vue-q-art>
    </div>
</template>

<script>
import axios from 'axios';
import VueQArt from 'vue-qart';

export default {
    data: function() {
        return {
            name: "",
            content: "",
            price: "",
            config: {
                value: "",
                imagePath: "../../../../assets/images/qr.png",
                filter: "color",
            }
        }
    },
    components: {
        VueQArt
    },
    mounted: function() {
        this.getProduct();
    },
    methods: {
        getProduct: function() {
            const id = String(this.$route.path).replace(/\/products\//, '');

            axios.get('/api/products/' + id).then((response) => {
                this.name = response.data.name;
                this.content = response.data.content;
                this.price = String(response.data.price);
                this.config.value = this.price;
            }, (error) => {
                alert(error);
            })
        }
    }
}
</script>