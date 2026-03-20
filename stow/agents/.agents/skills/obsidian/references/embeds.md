# Embeds Reference

## Notes

```markdown
![[Note Name]]                         Embed full note
![[Note Name#Heading]]                 Embed section
![[Note Name#^block-id]]               Embed block
```

## Images

```markdown
![[image.png]]                         Embed image
![[image.png|640x480]]                 Width x Height
![[image.png|300]]                     Width only (maintains ratio)
```

## External Images

```markdown
![Alt text](https://example.com/image.png)
![Alt text|300](https://example.com/image.png)
```

## Audio

```markdown
![[audio.mp3]]
![[audio.ogg]]
```

## PDF

```markdown
![[document.pdf]]
![[document.pdf#page=3]]
![[document.pdf#height=400]]
```

## Lists

```markdown
![[Note#^list-id]]
```

Where the list has a block ID:

```markdown
- Item 1
- Item 2

^list-id
```

## Search Results

````markdown
```query
tag:#project status:done
```
````

## Bases

```markdown
![[MyBase.base]]
![[MyBase.base#View Name]]
```
