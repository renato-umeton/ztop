#!/usr/bin/env python3

import asyncio
import subprocess
import signal
import sys
from typing import List, Optional
from rich.console import Console
from rich.layout import Layout
from rich.panel import Panel
from rich.live import Live
from rich.text import Text


class ProcessPane:
    def __init__(self, title: str, command: List[str]):
        self.title = title
        self.command = command
        self.process: Optional[subprocess.Popen] = None
        self.output_lines: List[str] = []
        self.max_lines = 50

    async def start(self):
        try:
            self.process = subprocess.Popen(
                self.command,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines=True,
                bufsize=1
            )
        except FileNotFoundError:
            self.output_lines = [f"Error: Command '{' '.join(self.command)}' not found"]

    def get_output(self) -> str:
        if not self.process:
            return "\n".join(self.output_lines)
        
        try:
            while True:
                line = self.process.stdout.readline()
                if not line:
                    break
                
                line = line.rstrip()
                if line:
                    self.output_lines.append(line)
                    if len(self.output_lines) > self.max_lines:
                        self.output_lines.pop(0)
        except:
            pass
        
        return "\n".join(self.output_lines[-self.max_lines:])

    def stop(self):
        if self.process:
            try:
                self.process.terminate()
                self.process.wait(timeout=2)
            except:
                try:
                    self.process.kill()
                except:
                    pass


class ZTop:
    def __init__(self):
        self.console = Console()
        self.layout = Layout()
        self.panes = {
            "htop_cpu": ProcessPane("htop (CPU)", ["htop", "--sort-key", "PERCENT_CPU"]),
            "htop_mem": ProcessPane("htop (Memory)", ["htop", "--sort-key", "PERCENT_MEM"]),
            "mactop": ProcessPane("mactop", ["mactop"]),
            "ctop": ProcessPane("ctop", ["ctop"])
        }
        self.running = True

    def setup_layout(self):
        self.layout.split_column(
            Layout(name="top", size=None),
            Layout(name="bottom", size=None)
        )
        
        self.layout["top"].split_row(
            Layout(name="top_left"),
            Layout(name="top_right")
        )
        
        self.layout["bottom"].split_row(
            Layout(name="bottom_left"),
            Layout(name="bottom_right")
        )

    def update_layout(self):
        self.layout["top_left"].update(
            Panel(
                Text(self.panes["htop_cpu"].get_output(), style="green"),
                title="htop (CPU Order)",
                border_style="bright_blue"
            )
        )
        
        self.layout["bottom_left"].update(
            Panel(
                Text(self.panes["htop_mem"].get_output(), style="yellow"),
                title="htop (Memory Order)",
                border_style="bright_yellow"
            )
        )
        
        self.layout["top_right"].update(
            Panel(
                Text(self.panes["mactop"].get_output(), style="cyan"),
                title="mactop",
                border_style="bright_cyan"
            )
        )
        
        self.layout["bottom_right"].update(
            Panel(
                Text(self.panes["ctop"].get_output(), style="magenta"),
                title="ctop",
                border_style="bright_magenta"
            )
        )

    async def start_processes(self):
        for pane in self.panes.values():
            await pane.start()

    def stop_processes(self):
        for pane in self.panes.values():
            pane.stop()

    def signal_handler(self, signum, frame):
        self.running = False
        self.stop_processes()

    async def run(self):
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
        
        self.setup_layout()
        await self.start_processes()
        
        with Live(self.layout, console=self.console, refresh_per_second=2) as live:
            while self.running:
                try:
                    self.update_layout()
                    await asyncio.sleep(0.5)
                except KeyboardInterrupt:
                    break
        
        self.stop_processes()


async def main():
    app = ZTop()
    try:
        await app.run()
    except KeyboardInterrupt:
        pass
    finally:
        app.stop_processes()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nExiting...")
        sys.exit(0)