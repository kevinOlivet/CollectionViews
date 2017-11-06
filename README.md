# CollectionViews
A collection of collectionViews!

This is a collection of collectionViews full of examples for future modification and use.

#CollectionViewImgurSearch

This project implements a dynamic collection view that displays search results from Imgur.
The collection view uses RESTful APIs to hit the Imgur api endpoint for it's galleries.
The search textField is used to search for images on Imgur with that tag.

A small thumbnail is displayed in the collectionViewCell.
Tapping the cell will expand the image and also download a larger version of the image.
The collectionView can be reordered by long pressing the image and dragging it.

Each search will be displayed in it's own section with the search term as the title.

Further, selected images can be shared via the UIActivityViewController.

This version uses a more complicated error handling system for the parsing of the JSON data.

In Imgur.swift there is my Client-ID.  Please don't abuse it.
It's easy and free to get your own here: https://api.imgur.com/oauth2/addclient
Just put in some application name, check the box for anonymous usage and give them an email address to receive it.
Easy. Free. Nice.

This project was inspired by the Ray Wenderlich tutorial here: https://www.raywenderlich.com/136161/uicollectionview-tutorial-reusable-views-selection-reordering
with substantial changes and revisions.

#CollectionViewSimple

This project is a simple example of a common CollectionView.

It implements the UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout.

Each is divided and marked to make reference easy to customize and reuse.

It also uses a function called randomColor() to provide a little variety in the colors when selected.
