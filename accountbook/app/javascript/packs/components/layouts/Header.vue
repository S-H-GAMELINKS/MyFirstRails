<template>
    <div>
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <router-link class="navbar-brand" to="/">Account Book</router-link>
            <div class="dropdown">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Menu
                </button>
                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                    <router-link to="/" class="dropdown-item">Top</router-link>
                    <router-link to="/category" class="dropdown-item">Category</router-link>
                </div>
            </div>
        </nav>
    </div>    
</template>