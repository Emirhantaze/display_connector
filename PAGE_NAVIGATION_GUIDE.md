# Page Navigation System Guide

## Overview

The TJC screen navigation system uses a multi-layer architecture:
1. **Page Constants** - String identifiers defined in `src/mapping.py`
2. **Page Mappers** - Maps constants to actual TJC page IDs (e.g., "main", "file1")
3. **Response Actions** - Maps button presses to actions (including navigation)
4. **Navigation History** - Tracks page navigation for back button functionality

## How Navigation Works

### 1. Page Constants (`src/mapping.py`)
Pages are defined as string constants:
```python
PAGE_MAIN = "main"
PAGE_FILES = "files"
PAGE_MY_NEW_PAGE = "my_new_page"  # Example
```

### 2. Page Mapping (`src/elegoo_display.py`)
The display mapper converts page constants to TJC page IDs:
```python
class ElegooDisplayMapper(Mapper):
    page_mapping = {
        PAGE_MAIN: "main",           # Constant -> TJC page ID
        PAGE_FILES: "file1",
        PAGE_MY_NEW_PAGE: "mypage",  # Your new page
    }
```

### 3. Navigation Function (`display.py`)
The `_navigate_to_page()` method:
- Maintains navigation history
- Maps page constant to TJC page ID
- Calls `display.navigate_to()` which sends `page <page_id>` command
- Handles special page logic via `special_page_handling()`

### 4. User Interactions (`src/response_actions.py`)
Button presses trigger actions:
```python
response_actions = {
    1: {  # Page ID (TJC page number)
        1: "files_picker",                    # Action
        2: "page " + PAGE_PREPARE_MOVE,       # Navigate to page
        3: "page " + PAGE_SETTINGS,
    }
}
```

## How to Add a New Page

### Step 1: Define Page Constant
Add to `src/mapping.py`:
```python
PAGE_MY_NEW_PAGE = "my_new_page"
```

### Step 2: Add to Page Mapper
Add to `src/elegoo_display.py`:
```python
class ElegooDisplayMapper(Mapper):
    page_mapping = {
        # ... existing pages ...
        PAGE_MY_NEW_PAGE: "your_tjc_page_id",  # TJC page ID from your .tft file
    }
```

### Step 3: Add Navigation Action
Add to `src/response_actions.py`:
```python
response_actions = {
    # Existing page (e.g., main page = 1)
    1: {
        # ... existing buttons ...
        7: "page " + PAGE_MY_NEW_PAGE,  # Button 7 navigates to new page
    },
    # Your new page (TJC page number)
    42: {  # Replace 42 with your actual TJC page number
        0: "go_back",                    # Back button
        1: "my_custom_action",           # Button 1 action
    }
}
```

### Step 4: Handle Special Page Logic (Optional)
Add to `special_page_handling()` in `display.py`:
```python
async def special_page_handling(self, current_page):
    # ... existing cases ...
    elif current_page == PAGE_MY_NEW_PAGE:
        # Initialize your page UI
        await self.display.update_my_new_page_ui()
```

### Step 5: Add Action Handler (If Needed)
Add to `execute_action()` in `display.py`:
```python
def execute_action(self, action):
    # ... existing actions ...
    elif action == "my_custom_action":
        # Handle your custom action
        self.send_gcode("M104 S200")
```

## Key Files Summary

| File | Purpose |
|------|---------|
| `src/mapping.py` | Defines page constants |
| `src/elegoo_display.py` | Maps constants to TJC page IDs for Neptune 4 |
| `src/response_actions.py` | Maps button presses to actions |
| `display.py` | Main controller with navigation logic |

## Navigation Flow Example

1. User presses button on TJC screen
2. `display_event_handler()` receives touch event
3. `handle_response()` looks up action in `response_actions`
4. Action `"page " + PAGE_MY_NEW_PAGE` triggers `execute_action()`
5. `execute_action()` calls `_navigate_to_page(PAGE_MY_NEW_PAGE)`
6. `_navigate_to_page()`:
   - Adds page to history
   - Maps constant to TJC ID via `mapper.map_page()`
   - Calls `display.navigate_to("your_tjc_page_id")`
   - Sends `"page your_tjc_page_id"` command to TJC screen
   - Calls `special_page_handling()` for page-specific logic

## Important Notes

- **TJC Page IDs**: Must match the page IDs in your `.tft` file
- **History Management**: The `history` list tracks navigation for back button
- **Tabbed Pages**: Pages in `TABBED_PAGES` list replace each other in history
- **Special Handling**: Use `special_page_handling()` for page initialization
- **Data Mapping**: Use `data_mapping` in mapper to update UI elements automatically

