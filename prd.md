# Product Requirements Document (PRD)

## DirXplore for iOS

### Native Swift Edition (Personal Sideload Build)

---

# Project Overview

**Project Name:** DirXplore **app package name:**com.example.dirBrowser

**Platform:** iOS (Native Swift)

**Target Device:** iPhone 15 Pro

**Deployment:** Personal use via sideloading (unsigned IPA)

**Language:** Swift 6

**UI Framework:** SwiftUI

**Architecture:** MVVM + Observation + Swift Concurrency

**Minimum iOS:** iOS 18+

**Primary Goal**

Create a premium, native iOS application that allows browsing open HTTP directories, crawling websites, downloading files, managing downloads, searching torrents, streaming media, and providing an experience indistinguishable from a first-party Apple application.

The app should prioritize smooth animations, efficient memory usage, native iOS interactions, and full compatibility with iPhone 15 Pro.

---

# Core Design Principles

The application must feel like an Apple-designed application.

Never use Android-inspired UI.

Everything should respect Human Interface Guidelines.

Use:

* Native navigation
* Native sheets
* Native menus
* Native gestures
* Native animations
* Native typography
* Native haptics
* Native blur materials

The UI should feel fluid and responsive at 120 Hz on the iPhone 15 Pro's ProMotion display.

---

# Technology Stack

## Language

Swift 6

## UI

SwiftUI

## Architecture

MVVM

Observation Framework

Swift Concurrency

Actors

Task Groups

Async/Await

## Storage

SwiftData

## Networking

URLSession

Network.framework

## HTML Parsing

SwiftSoup

## Torrent Engine

libtorrent-rasterbar (compiled for iOS)

## Streaming

AVFoundation

AVPlayer

## Security

LocalAuthentication

CryptoKit

## Live Activities

ActivityKit

## Widgets

WidgetKit

## Dynamic Island

ActivityKit

## File Access

FileManager

UIDocumentPicker

Security Scoped Bookmarks

## Image Loading

Native AsyncImage

## Logging

OSLog

---

# App Structure

```
DirXplore

Home

Browser

Crawler

Downloads

Torrent

Media

History

Favorites

Settings

Security
```

Bottom Navigation

1 Browser

2 Downloads

3 Torrent

4 Favorites

5 Settings

---

# Browser Module

Capabilities

Open HTTP directories

Apache

Nginx

Lighttpd

Index listings

Features

Auto detect folders

Auto detect files

File icons

File previews

Sorting

Search

Breadcrumb navigation

Back

Forward

Up folder

Refresh

Pull to refresh

Bookmark folders

Favorite directories

Copy URLs

Open externally

Share links

History

Open in browser

---

# Deep Crawler

Completely rewritten for Swift.

Features

Breadth First Search

Concurrent crawling

Pause

Resume

Cancel

Maximum depth

Ignore duplicate URLs

Exclude extensions

Exclude folders

Real-time progress

Estimated remaining folders

Live statistics

Runs using TaskGroup

No UI blocking

---

# Smart Categorization

Automatically detect

Movies

TV Shows

Anime

Music

Games

Applications

Books

Archives

Images

Documents

Adult content (optional toggle)

Detection should use

Filename

Extension

Keywords

Folder names

---

# Download Manager

Support

HTTP

HTTPS

Resume downloads

Range requests

Parallel downloads

Queue

Pause

Resume

Retry

Stop

Reorder queue

Priorities

Low

Normal

High

Maximum simultaneous downloads configurable.

Display

Progress

Speed

ETA

Remaining size

Downloaded size

Average speed

Peak speed

Network activity

---

# Download Details

Each download displays

Progress ring

Percentage

Current speed

Remaining time

Downloaded

File size

Resume support

Status

Destination

Hash

Open

Reveal in Files

Share

Delete

---

# Torrent Hub

Sections

Search

Active

History

Completed

Settings

Search

Instant search

Magnet support

Torrent file import

Sorting

Seeders

Leechers

Size

Date

Alphabetical

---

# Torrent Downloads

Features

Sequential mode

File priorities

Pause

Resume

Force recheck

Seed ratio

Maximum upload speed

Maximum download speed

Tracker list

Peer list

Statistics

Downloaded

Uploaded

Availability

Connections

Pieces

Progress

---

# Streaming

Support

Video

Audio

Sequential streaming

Internal player

External player

AirPlay

Picture in Picture

Subtitles

Audio track selection

Playback speed

Continue watching

---

# Media Player

Controls

Double tap seek

Swipe brightness

Swipe volume

Pinch zoom

Subtitle selection

Audio selection

Picture in Picture

Gesture lock

Mini player

Landscape optimized

---

# Favorites

Save directories

Save torrents

Save searches

Recent folders

Pinned folders

Pinned downloads

---

# Search

Browser search

Torrent search

History search

Instant suggestions

Recent searches

---

# Security

Face ID

Touch ID

PIN

Auto lock

Privacy blur

Require unlock on launch

Protect downloads

Protect settings

---

# Settings

Appearance

Accent color

Theme

OLED mode

Downloads

Default folder

Concurrent downloads

Torrent

Streaming

Network

Security

About

Diagnostics

Logs

---

# Native iOS Features

## Dynamic Island

Download progress

Torrent progress

Estimated time

Current speed

Pause

Resume

Cancel

## Live Activities

Real-time progress

Remaining time

Speed

Download name

## Widgets

Recent downloads

Favorites

Quick open

Recent torrents

## Haptics

Selection

Success

Failure

Warning

Completion

## Context Menus

Preview

Share

Copy

Favorite

Delete

Rename

Open

---

# Files Integration

Import files

Export files

Move files

Share

Reveal in Files

Document Picker

Security scoped access

---

# Performance

App launch

<1 second

Scrolling

120 FPS

Memory

<350 MB during heavy crawling

Download manager

Stable with 25 concurrent downloads

Crawler

50,000+ folders without blocking UI

Battery

Optimized background usage

---

# Accessibility

VoiceOver

Dynamic Type

High Contrast

Reduce Motion

Reduce Transparency

Keyboard support (iPad)

---

# Error Handling

Graceful retry

Offline mode

Network recovery

Automatic reconnection

Corrupted download detection

Disk full detection

Permission handling

---

# Logging

OSLog

Network logs

Download logs

Crawler logs

Torrent logs

Crash diagnostics

---

# Build Configuration

Target

iPhone 15 Pro

iOS 18+

Swift 6

Release optimized

Whole Module Optimization

Strict Concurrency

---

# Sideload Compatibility

The application is intended for personal sideloading and should:

* Build into an unsigned IPA suitable for signing and sideloading.
* Avoid dependencies on App Store-specific services unless optional.
* Function fully without Apple account sign-in.
* Keep all user data stored locally by default, with optional cloud integration if added later.

---

# AI Development Requirements

The AI agent should:

* Produce clean, modular, production-quality Swift code.
* Use modern SwiftUI and avoid UIKit unless a native API requires it.
* Follow SOLID principles and protocol-oriented programming.
* Keep business logic separate from UI.
* Use dependency injection for services.
* Write unit tests for core services where practical.
* Avoid placeholder implementations unless explicitly marked with `TODO`.
* Ensure the app compiles without warnings or errors.
* Build features incrementally in small, testable milestones.
* Prioritize responsiveness, low memory usage, and battery efficiency.

This PRD provides a solid blueprint for building a premium, native iOS version of DirXplore optimized for your iPhone 15 Pro and personal sideloading workflow while respecting iOS's platform capabilities and limitations.
