<template>
    <div class="container">
        <form>
            <div class="form-group">
                <label>Name</label>
                <input class="form-control" v-model="name" placeholder="Input your product title ......">
            </div>
            <div class="form-group">
                <label>Content</label>
                <vue-editor v-model="content" :editorOptions="editorSettings">
                </vue-editor>
            </div>
            <div class="form-group">
                <label>Price</label>
                <input v-model="price">
            </div>
        </form>
        <p>
            <button type="button" class="btn btn-primary" v-if="creatable" v-on:click="createProduct">Create</button>
            <button type="button" class="btn btn-primary" v-if="editable" v-on:click="editProduct">Update</button>
        </p>
    </div>
</template>

<script>
import axios from 'axios';
import { VueEditor, Quill } from 'vue2-editor';
import { ImageDrop } from "quill-image-drop-module";
import { ImageResize } from "quill-image-resize-module";

Quill.register("modules/imageDrop", ImageDrop);
Quill.register("modules/imageResize", ImageResize);

export default {
    data: function() {
        return {
            name: "",
            content: "",
            price: "",
            editorSettings: {
                modules: {
                    imageDrop: true,
                    imageResize: {}
                }
            },
            creatable: false,
            editable: false
        }
    },
    components: {
        VueEditor
    },
    mounted: function() {
        this.checkAddress();
        if(this.editable) {
            this.getProduct();
        }
    },
    methods: {
        checkAddress: function() {

            const url = String(this.$route.path);
            if(url.match(/edit/)) {
                this.editable = true;
            } else {
                this.creatable = true;
            }
        },
        getProduct: function() {

            const id = String(this.$route.path).replace(/\/products\//, '').replace(/\/edit/, '');

            axios.get('/api/products/' + id).then((response) => {
                this.name = response.data.name;
                this.content = response.data.content;
                this.price = String(response.data.price);
            }, (error) => {
                alert(error);
            })
        },
        createProduct: function() {

            axios.post('/api/products', {product: {name: this.name, content: this.content, price: this.price}}).then((response) => {
                if (this.title === "" || this.content === "" || this.price === "") {
                    alert("Can't be black in Title, Content, Price!!");
                } else {
                    alert("Success!");
                    this.$router.push({path: '/products'});
                }
            }, (error) => {
                alert(error);
            })
        },
        editProduct: function() {
            
            const id = String(this.$route.path).replace(/\/products\//, '').replace(/\/edit/, '');

            axios.put('/api/products/' + id, {product: {name: this.name, content: this.content, price: this.price}}).then((response) => {
                if (this.title === "" || this.content === "" || this.price === "") {
                    alert("Can't be black in Title or Content, Price!!");
                } else {
                    alert("Success!");
                    this.$router.push({path: '/products'});
                }
            }, (error) => {
                alert(error);
            })
        }
    }
}
</script>