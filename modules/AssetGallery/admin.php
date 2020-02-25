<?php

$app->on('admin.init', function() {
    $this->helper('admin')->addAssets('assetgallery:assets/component.js');
    $this->helper('admin')->addAssets('assetgallery:assets/field-assetgallery.tag');
});

?>
