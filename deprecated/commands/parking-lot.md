# Parking Lot Command

You are helping the user capture and organize future ideas that aren't part of the immediate critical path.

## Context

During design sessions, good ideas emerge that are valuable but not essential for the through-line. Rather than lose these ideas or let them clutter the core design, we capture them in a parking lot.

The parking lot is:
- A holding area for future enhancements
- Organized and categorized for easy reference
- A living document that grows over time
- NOT a dumping ground - ideas should still be thoughtful

## Your Task

**Manage the parking lot in `design/parking-lot.md`**

## Process

### 1. Check for Existing Parking Lot

- If `design/parking-lot.md` exists, read it
- If not, create it with initial structure

### 2. Capture Ideas Conversationally

Ask the user:
- "What ideas do you want to park for later?"
- "Any enhancements that came up during design?"
- "Features that would be nice but aren't critical?"

Listen for ideas mentioned during other design commands too.

### 3. Categorize Ideas

Organize ideas into logical categories:

**Common categories:**
- **Features** - New capabilities or functionality
- **Optimizations** - Performance, scaling, efficiency improvements
- **Integrations** - External services or systems to connect
- **User Experience** - UI/UX enhancements
- **Infrastructure** - Architecture or deployment improvements
- **Analytics & Monitoring** - Observability and insights
- **Security** - Security enhancements beyond basics
- **Automation** - Workflow or process automation

Create new categories as needed.

### 4. Write Clear, Actionable Ideas

Each idea should:
- Be concise (1-2 sentences)
- Explain the value or "why"
- Be specific enough to act on later

**Good examples:**
- "Add scheduled publishing so articles can be queued and auto-published at optimal times"
- "Integrate with social media APIs to auto-share published articles and track engagement"
- "Implement A/B testing for article titles to optimize click-through rates"

**Avoid vague:**
- "Make it better"
- "Add more features"
- "Improve performance"

### 5. Keep It Organized

- Group related ideas together
- Use consistent formatting
- Add new ideas to existing categories when appropriate
- Create new categories only when needed

## Document Structure

```markdown
# Parking Lot: Future Ideas

*Ideas and enhancements to consider after the through-line is working.*

---

## Features

- **[Feature name]** - Description and value proposition
- **[Feature name]** - Description and value proposition

## Optimizations

- **[Optimization name]** - What it improves and why it matters
- **[Optimization name]** - What it improves and why it matters

## Integrations

- **[Integration name]** - What it connects to and the benefit
- **[Integration name]** - What it connects to and the benefit

## User Experience

- **[UX enhancement]** - How it improves the user experience
- **[UX enhancement]** - How it improves the user experience

## Infrastructure

- **[Infrastructure idea]** - What it enables or improves
- **[Infrastructure idea]** - What it enables or improves

## Analytics & Monitoring

- **[Analytics idea]** - What insights it provides
- **[Monitoring idea]** - What it helps track or detect

## Security

- **[Security enhancement]** - What it protects or prevents

## Automation

- **[Automation idea]** - What it automates and the benefit

---

## Notes

*Any additional context or considerations for future planning.*
```

## Example Parking Lot

```markdown
# Parking Lot: Future Ideas

*Ideas and enhancements to consider after the through-line is working.*

---

## Features

- **Multi-platform publishing** - Publish to Medium, Dev.to, and personal blog simultaneously
- **Content calendar** - Visual calendar showing scheduled and published articles
- **Topic suggestions based on audience** - AI suggests topics based on reader engagement data

## Optimizations

- **Batch processing** - Process multiple research sources in parallel for faster topic discovery
- **Caching layer** - Cache frequently used research data to reduce API calls

## Integrations

- **Google Analytics** - Track article performance and reader behavior
- **Email newsletter** - Auto-send new articles to subscriber list
- **SEO tools** - Integrate with SEMrush or Ahrefs for keyword research

## User Experience

- **Rich text editor** - WYSIWYG editor for article refinement
- **Preview mode** - See how article will look before publishing
- **Mobile app** - Review and approve articles on mobile

## Infrastructure

- **CDN for images** - Faster image delivery for embedded media
- **Multi-region deployment** - Reduce latency for global users

---

## Notes

- Consider authentication/authorization once we have multiple users
- May need billing/subscription system for commercial launch
```

## Key Principles

1. **Capture, don't commit** - Good ideas go here, decisions come later
2. **Organized, not overwhelming** - Categories help manage growth
3. **Specific, not vague** - Each idea should be actionable when needed
4. **Living document** - Grows and evolves with the project
5. **Value-focused** - Always explain why an idea matters

## After Updating

Once parking lot is updated:
- Show the new/updated ideas
- Confirm they're captured correctly
- Ask: "Any other ideas to park?"
- Remind: "These are all post-through-line - we'll revisit when ready"
