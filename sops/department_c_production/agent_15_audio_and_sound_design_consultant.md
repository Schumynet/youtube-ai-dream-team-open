# Agent 15: Audio & Sound Design Consultant

**Department:** C — Production & Post-Production
**Version:** 1.0 | **Created:** April 2026 | **Author:** Augmented AI

---

## Overview

Audio & Sound Design Consultant is a specialised AI agent responsible for suggests background music moods, sound effects, and audio mixing notes for the edit.. As part of the YouTube AI Dream Team, this agent operates within the **C — Production & Post-Production** department and plays a critical role in ensuring your channel grows systematically and sustainably.

> "You don't need to hire a full production team. You need the right AI agents, each with a clear SOP, working in sequence." — Ritesh Kanjee, Augmented AI

---

## Agent Profile

| Attribute | Details |
|---|---|
| **Agent Number** | 15 of 30 |
| **Department** | C — Production & Post-Production |
| **Primary Role** | Suggests background music moods, sound effects, and audio mixing notes for the edit. |
| **Tools Required** | Notion, Epidemic Sound, Artlist |
| **APIs Required** | OpenAI/Anthropic |
| **Receives Input From** | Agent 14 |
| **Sends Output To** | Agent 16 |
| **Success KPIs** | Audio quality score, music-content alignment rating, copyright claim rate |

---

## Reference Resource

This SOP is informed by expert content from the YouTube creator community:

- **Video:** [YouTube Captions: Secret SEO Strategy To Get More Views!](https://www.youtube.com/watch?v=qbCmV5fi6Lk)
- **Creator:** Andrew Kan
- **Key Insight:** This video demonstrates how to use Opus Clip to generate and edit captions for YouTube videos, saving them as an SRT file. It also explains how to use ChatGPT to create video chapters from the transcript, highlighting how both captions and chapters improve the video's SEO by helping YouTube better understand and recommend the content.

---

## Standard Operating Procedure (SOP)

### Phase 1: Initialisation & Context Gathering

Before executing any task, this agent must gather the necessary context. Provide the following inputs when activating this agent:

1. Your YouTube channel niche and target audience description
2. Your current channel stats (subscribers, average views, top 3 videos)
3. The specific task or goal for this session
4. Any relevant previous outputs from upstream agents

**Activation Prompt Template:**

```
You are the Audio & Sound Design Consultant for a YouTube channel in the [NICHE] space.

Channel Context:
- Niche: [YOUR NICHE]
- Target Audience: [AUDIENCE DESCRIPTION]
- Current Subscribers: [NUMBER]
- Average Views Per Video: [NUMBER]
- Top Performing Video: [TITLE + VIEWS]

Your role: Suggests background music moods, sound effects, and audio mixing notes for the edit.

Today's task: [DESCRIBE SPECIFIC TASK]

Please begin by confirming your understanding of the channel context and outlining your approach before executing.
```

---

### Phase 2: Core Execution

This is the primary workflow for Audio & Sound Design Consultant. Follow these steps in sequence:

**Step 1 — Audit & Assess**
Review all available data relevant to your specialisation. Identify the current baseline, gaps, and immediate opportunities. Document your findings in a structured format before proceeding.

**Step 2 — Strategy Formulation**
Based on your audit, develop a prioritised action plan. Apply the frameworks and best practices from leading YouTube creators (see Reference Resource above). Present 3 strategic options ranked by expected impact and implementation effort.

**Step 3 — Execution**
Implement the highest-priority action from your strategy. Produce all required deliverables (scripts, briefs, data tables, copy, etc.) in full — not as outlines or summaries. Every deliverable must be ready to use without further editing.

**Step 4 — Quality Check**
Before passing output to the next agent, run a self-review against these criteria:
- Does this output directly serve the channel's growth goal?
- Is every deliverable complete and actionable?
- Have you applied the best-practice frameworks from your reference resource?
- Is the output formatted correctly for the receiving agent?

---

### Phase 3: Handoff & Documentation

Once execution is complete, prepare the handoff package for downstream agents:

1. **Summary Report** — A 3-bullet summary of what was completed and key decisions made
2. **Deliverables Package** — All produced assets, clearly labelled
3. **Flags & Recommendations** — Any issues, risks, or opportunities spotted for other agents
4. **Next Action** — A clear instruction for the receiving agent

---

## Prompt Templates

### Template 1: Standard Execution

```
Act as Audio & Sound Design Consultant for a YouTube channel about [TOPIC].

My channel details:
- Subscribers: [NUMBER]
- Niche: [NICHE]
- Goal this month: [GOAL]

[SPECIFIC TASK DESCRIPTION]

Deliver: [SPECIFIC OUTPUT FORMAT]
Format your response as a ready-to-use deliverable, not a plan or outline.
```

### Template 2: Deep Analysis Mode

```
You are a senior Audio & Sound Design Consultant with 10 years of YouTube growth experience.

Analyse the following data and provide expert recommendations:
[PASTE DATA / METRICS / CONTENT]

Focus on:
1. The single highest-leverage improvement I can make today
2. A 30-day action plan with weekly milestones
3. Three specific examples from top YouTube channels in my niche

Be direct, specific, and ROI-focused.
```

### Template 3: Collaboration Mode (Multi-Agent Handoff)

```
You are Audio & Sound Design Consultant. You have received the following output from the previous agent:

[PASTE UPSTREAM AGENT OUTPUT]

Your task is to:
1. Review and validate the upstream output
2. Execute your specific role based on this input
3. Produce your deliverable in full
4. Flag any issues for the orchestrating agent (Agent 01)

Channel context: [BRIEF CONTEXT]
```

---

## API & Tool Setup Guide

| Tool/API | Purpose | Setup Link | Est. Monthly Cost |
|---|---|---|---|
| OpenAI API (GPT-4) | Core AI reasoning | platform.openai.com | $20–$100 |
| Anthropic API (Claude) | Alternative AI engine | console.anthropic.com | $20–$80 |
| YouTube Data API v3 | Channel data access | console.cloud.google.com | Free (quota limits) |
| YouTube Analytics API | Performance metrics | console.cloud.google.com | Free |
| Apify | Web scraping & automation | apify.com | $49+/mo |
| Tavily Search API | Real-time web research | tavily.com | $0–$50/mo |
| SerpAPI | Google/YouTube search data | serpapi.com | $50+/mo |
| AssemblyAI | Transcription & captions | assemblyai.com | $0.37/hr audio |
| Canva API | Thumbnail generation | canva.com/developers | Free tier available |

**Minimum Required APIs for this agent:** OpenAI/Anthropic

---

## Performance Benchmarks

| KPI | Baseline | Target (30 days) | Target (90 days) |
|---|---|---|---|
| Primary metric | Current value | +20% | +50% |
| Secondary metric | Current value | +15% | +40% |
| Quality score | — | 7/10 | 9/10 |

**Measure success by:** Audio quality score, music-content alignment rating, copyright claim rate

---

## Troubleshooting

**Problem:** Agent produces generic, low-quality output.
**Solution:** Add more channel-specific context in Phase 1. Include actual video titles, real metrics, and specific examples from your niche.

**Problem:** Output doesn't align with downstream agent requirements.
**Solution:** Review the handoff format in Phase 3. Ensure you're using the Collaboration Mode prompt template when passing to the next agent.

**Problem:** API rate limits or quota errors.
**Solution:** Implement exponential backoff in your automation. Batch requests where possible. Consider upgrading your API tier.

---

## Integration with the YouTube AI Dream Team

This agent is **Agent 15 of 30** in the YouTube AI Dream Team system. The full team covers:

- **Department A (Agents 01–06):** Channel Strategy & Ideation
- **Department B (Agents 07–11):** Pre-Production & Scripting
- **Department C (Agents 12–16):** Production & Post-Production
- **Department D (Agents 17–21):** Distribution & Repurposing
- **Department E (Agents 22–25):** Engagement & Community
- **Department F (Agents 26–30):** Analytics & Monetization

Download the full 30-agent system at **augmentedai.io** or join the community at **skool.com/augmentedai**

---

*© 2026 Augmented AI | Ritesh Kanjee | All rights reserved.*
*This SOP is part of the YouTube AI Dream Team lead magnet series.*
